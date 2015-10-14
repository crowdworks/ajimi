require 'spec_helper'

describe Ajimi::Checker do
  let(:config) { {
    source: (Ajimi::Server.new("source_host_value", {
        ssh_options: {
          host: "overriden_source_host_value",
          user: "source_user_value",
          key: "source_key_value"
        }
      }
    )),
    target: (Ajimi::Server.new("target_host_value", {
        ssh_options: {
          user: "target_user_value",
          key: "target_key_value"
        }
      }
    )),
    check_root_path: "check_root_path_value",
    ignored_paths: ["/path_to_ignored1", "/path_to_ignored2"],
    ignored_contents: ({"/path_to_content" => /ignored_pattern/}),
    pending_paths: ["/path_to_pending1", "/path_to_pending2"],
    pending_contents: ({"/path_to_content" => /pending_pattern/})
  } }
  let(:checker) { Ajimi::Checker.new(config) }
  let(:source) { checker.source }
  let(:target) { checker.target }

  before do

  end

  describe "#check" do
    let(:find1) { "path1, mode1, user1, group1, bytes1" }
    let(:find2) { "path2, mode2, user2, group2, bytes2" }
    let(:find2_changed) {"path2, mode2, user2, group2, bytes2_changed" }

    context "when 2 servers have same entries" do
      it "returns true" do
        allow(source).to receive(:find).and_return([find1, find2])
        allow(target).to receive(:find).and_return([find1, find2])
        expect(checker.check).to be true
      end
    end

    context "when 2 servers have different entries" do
      it "returns false" do
        allow(source).to receive(:find).and_return([find1, find2])
        allow(target).to receive(:find).and_return([find1, find2_changed])
        expect(checker.check).to be false
      end

      it "returns diff position" do
        allow(source).to receive(:command_exec).and_return(<<-SOURCE_STDOUT
/root, dr-xr-x---, root, root, 4096
/root/.bash_history, -rw-------, root, root, 4847
/root/.bash_logout, -rw-r--r--, root, root, 18
/root/.bash_profile, -rw-r--r--, root, root, 176
/root/.bashrc, -rw-r--r--, root, root, 176
/root/.cshrc, -rw-r--r--, root, root, 100
        SOURCE_STDOUT
        )
        allow(target).to receive(:command_exec).and_return(<<-TARGET_STDOUT
/root, dr-xr-x---, root, root, 4096
/root/.bash_logout, -rw-r--r--, root, root, 18
/root/.bash_profile, -rw-r--r--, root, root, 176
/root/.bashrc, -rw-r--r--, root, root, 176
/root/.cshrc, -rw-r--r--, root, root, 100
/root/.ssh, drwx------, root, root, 4096
        TARGET_STDOUT
        )
        checker.check
        expect(checker.diffs.first.first.position).to be 1
        expect(checker.diffs.last.first.position).to be 5

      end
    end

  end

  let(:source_find1) { "/root, dr-xr-x---, root, root, 4096" }
  let(:source_find2) { "/root/.bash_history, -rw-------, root, root, 4847" }
  let(:source_find3) { "/root/.bash_logout, -rw-r--r--, root, root, 18" }
  let(:source_find4) { "/root/.ssh/authorized_keys, -rw-------, root, root, 1099" }

  let(:target_find1) { "/root, dr-xr-x---, root, root, 4096" }
  let(:target_find1_changed) { "/root, dr-xr-x---, hoge, root, 4096" }

  let(:target_find2) { "/root/.bash_history, -rw-------, root, root, 4847" }
  let(:target_find2_changed) { "/root/.bash_history, -rw-------, root, hoge, 4847" }

  let(:target_find3) { "/root/.bash_logout, -rw-r--r--, root, root, 18" }
  let(:target_find3_changed) { "/root/.bash_logout, -rw-r--r--, root, root, 118" }

  let(:source_entry1) { make_entry(source_find1) }
  let(:source_entry2) { make_entry(source_find2) }
  let(:source_entry3) { make_entry(source_find3) }
  let(:source_entry4) { make_entry(source_find4) }

  let(:target_entry1) { make_entry(target_find1) }
  let(:target_entry1_changed) { make_entry(target_find1_changed) }
  let(:target_entry2) { make_entry(target_find2) }
  let(:target_entry3) { make_entry(target_find3) }
  let(:target_entry3_changed) { make_entry(target_find3_changed) }

  describe "#diff_entries" do

    let(:diffs) { checker.diff_entries(source_find, target_find) }

    context "when source and target have same entry" do
      let(:source_find) { [source_find1, source_find2, source_find3] }
      let(:target_find) { [target_find1, target_find2, target_find3] }

      it "has empty list" do
        expect(diffs.empty?).to be true
      end
    end
    
    context "when target has entry2" do
      let(:source_find) { [source_find1] }
      let(:target_find) { [target_find1, target_find2] }

      it "has + entry" do
        expect(diffs.first.first.action).to eq "+"
        expect(diffs.first.first.element).to eq target_entry2
      end
    end

    context "when target does not have entry2" do
      let(:source_find) { [source_find1, source_find2, source_find3] }
      let(:target_find) { [target_find1, target_find3] }

      it "has - entry" do
        expect(diffs.first.first.action).to eq "-"
        expect(diffs.first.first.element).to eq source_entry2
      end
    end

    context "when entry3 has changed" do
      let(:source_find) { [source_find1, source_find3] }
      let(:target_find) { [target_find1, target_find3_changed] }

      it "has - entry" do
        expect(diffs.first.first.action).to eq "-"
        expect(diffs.first.first.element).to eq source_entry3
      end
      it "has + entry" do
        expect(diffs.first.last.action).to eq "+"
        expect(diffs.first.last.element).to eq target_entry3_changed
      end

    end

  end

  describe "#filter_ignored_and_pending_paths" do
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:source_find) { [source_find1] }
    let(:target_find) { [target_find1, target_find2] }
    let(:ret) { checker.filter_ignored_and_pending_paths(diffs, ignored_paths, pending_paths) }

    context "when both ignored_paths and pending_paths are empty" do
      let(:ignored_paths) { [] }
      let(:pending_paths) { [] }
      it "does nothing" do
        expect(ret).to eq diffs
      end
    end

    context "when ignored_paths is empty" do
      let(:ignored_paths) { [] }
      it "does not call filter_path with ignored_paths" do
        expect(checker).not_to receive(:filter_paths).with(diffs, ignored_paths)
      end
    end

    context "when ignored_paths is not empty" do
      let(:ignored_paths) { [target_entry2.path] }
      let(:pending_paths) { [] }
      it "removes entry from diffs and set to ignored_by_path" do
        expect(ret.flatten.empty?).to eq true
        expect(checker.ignored_by_path).to eq ignored_paths
      end
    end

    context "when pending_paths is empty" do
      let(:pending_paths) { [] }
      it "does not call filter_path with pending_paths" do
        expect(checker).not_to receive(:filter_paths).with(diffs, pending_paths)
      end
    end

    context "when pending_paths is not empty" do
      let(:ignored_paths) { [] }
      let(:pending_paths) { [target_entry2.path] }
      it "removes entry from diffs and set to pending_by_path" do
        expect(ret.flatten.empty?).to eq true
        expect(checker.pending_by_path).to eq pending_paths
      end
    end

  end

  describe "#filter_paths" do
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:filterd) { checker.filter_paths(diffs, filter_paths) }
    context "when filter_paths is empty" do
      let(:source_find) { [source_find1] }
      let(:target_find) { [target_find1, target_find2] }
      let(:filter_paths) { [] }

      it "return empty list" do
        expect(filterd.empty?).to eq true
      end
    end

    context "when filter list has strings" do
      let(:source_find) { [source_find1, source_find3] }
      let(:target_find) { [target_find1, target_find2, target_find3_changed] }
      let(:filter_paths) { ["/hoge", "/root/.bash_logout"] }

      it "returns filterd list using ==" do
        expect(filterd).to eq ["/root/.bash_logout"]
      end
    end

    context "when filter list has regexp" do
      let(:source_find) { [source_find1, source_find3, source_find4] }
      let(:target_find) { [target_find1, target_find2, target_find3_changed] }
      let(:filter_paths) { [%r|\A/root/\.bash.*|] }

      it "returns filterd list using match" do
        expect(filterd).to eq ["/root/.bash_history", "/root/.bash_logout"]
      end
    end

    context "when filter list has unknown type" do
      let(:source_find) { [source_find1, source_find3, source_find4] }
      let(:target_find) { [target_find1, target_find2, target_find3_changed] }
      let(:filter_paths) { [1, 2, 3] }

      it "raises error TypeError" do
        expect{ checker.filter_paths(diffs, filter_paths) }.to raise_error(TypeError)
      end
    end

  end

  describe "#filter_ignored_and_pending_contents" do
    let(:source_find) { [source_find2] }
    let(:target_find) { [target_find2_changed] }
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:source_find2_contents) { ["HOGE"] }
    let(:target_find2_contents) { ["FUGA"] }
    let(:limit_check_contents) { 0 }
    let(:ret) { checker.filter_ignored_and_pending_contents(diffs, ignored_contents, pending_contents, limit_check_contents)}
    before do
      expect(source).to receive(:cat_or_md5sum).and_return(source_find2_contents)
      expect(target).to receive(:cat_or_md5sum).and_return(target_find2_contents)
    end
    context "when contents diffs doesn't match with both ignored_contents and pending_contents" do
      let(:ignored_contents) { { source_entry2.path => /hoge/ } }
      let(:pending_contents) { { source_entry2.path => /fuga/ } }
      let(:diff_contents_cache) { <<-DIFF_CONTENTS_CACHE
--- overriden_source_host_value: /root/.bash_history
+++ target_host_value: /root/.bash_history

- 0 HOGE
+ 0 FUGA
        DIFF_CONTENTS_CACHE
      }
      it "stores diff_contents_cache" do
        expect(ret).to eq diffs
        expect(checker.diff_contents_cache).to eq diff_contents_cache
      end
    end

    context "when contents diffs match with ignored_contents" do
      let(:ignored_contents) { { source_entry2.path => /(HOGE)|(FUGA)/ } }
      let(:pending_contents) { { source_entry2.path => /fuga/ } }
      it "removes entry from diffs and set to ignored_by_contents" do
        expect(ret.flatten.empty?).to eq true
        expect(checker.ignored_by_content).to eq [source_entry2.path]
      end
    end

    context "when contents diffs match with pending_contents" do
      let(:ignored_contents) { { source_entry2.path => /fuga/ } }
      let(:pending_contents) { { source_entry2.path => /(HOGE)|(FUGA)/ } }
      it "removes entry from diffs and set to pending_by_contents" do
        expect(ret.flatten.empty?).to eq true
        expect(checker.pending_by_content).to eq [source_entry2.path]
      end
    end

  end

  describe "#uniq_diff_file_paths" do
    let(:source_find) { [source_find1, source_find2, source_find3] }
    let(:target_find) { [target_find1_changed, target_find2_changed, target_find3_changed] }
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:file_paths) { checker.uniq_diff_file_paths(diffs) }

    it "returns differed file paths" do
      expect(file_paths).to eq [source_entry2.path, source_entry3.path]
    end

    it "returns uniq Array" do
      expect(file_paths.uniq).to eq file_paths
    end

    it "does not included dir" do
      expect(file_paths).not_to include source_entry1.path
    end

  end

  describe "#split_diff_file_paths" do
    let(:source_find) { [source_find1, source_find2, source_find3] }
    let(:target_find) { [target_find1_changed, target_find2_changed, target_find3_changed] }
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:file_paths) { checker.split_diff_file_paths(diffs) }

    it "splits diffs to minus and plus" do
      expect(file_paths.first).to eq [source_entry2.path, source_entry3.path]
      expect(file_paths.last).to eq [target_entry2.path, target_entry3.path]
    end

    it "does not included dir" do
      expect(file_paths).not_to include source_entry1.path
    end

  end

  describe "#union_set_diff_file_paths" do
    let(:source_find) { [source_find1, source_find2, source_find4] }
    let(:target_find) { [target_find1_changed, target_find2_changed, target_find3_changed] }
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:file_paths) { checker.union_set_diff_file_paths(diffs) }

    it "returns union set of minus and plus" do
      expect(file_paths).to eq [source_entry2.path, target_entry3.path, source_entry4.path]
    end

  end

  describe "#product_set_file_paths" do
    let(:source_find) { [source_find1, source_find2, source_find4] }
    let(:target_find) { [target_find1_changed, target_find2_changed, target_find3_changed] }
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:file_paths) { checker.product_set_file_paths(diffs) }

    it "returns product set of minus and plus" do
      expect(file_paths).to eq [source_entry2.path]
    end

  end

  describe "#diff_file" do
    let(:source_find2_contents) { ["HOGE"] }
    let(:target_find2_contents) { ["FUGA"] }
    let(:ret) { checker.diff_file(source_entry2.path) }
    before do
      expect(source).to receive(:cat_or_md5sum).and_return(source_find2_contents)
      expect(target).to receive(:cat_or_md5sum).and_return(target_find2_contents)
    end
    it "returns diffs content" do
      expect(ret.flatten.empty?).to eq false
      expect(ret.first.first.element.to_s).to eq "HOGE"
      expect(ret.first.last.element.to_s).to eq "FUGA"
    end
  end

  describe "#filter_diff_file" do
    let(:source_find2_contents) { ["HOGE"] }
    let(:target_find2_contents) { ["FUGA"] }
    let(:diffs) { checker.diff_file(source_entry2.path) }
    before do
      expect(source).to receive(:cat_or_md5sum).and_return(source_find2_contents)
      expect(target).to receive(:cat_or_md5sum).and_return(target_find2_contents)
    end

    context "when filter_pattern is nil" do
      it "returns diffs just as it is" do
        expect(checker.filter_diff_file(diffs, nil)).to eq diffs
      end
    end

    context "when filter_pattern is not nil" do
      let(:ret) { checker.filter_diff_file(diffs, /HOGE/) }
      it "returns filtered diffs" do
        expect(ret.first.first.element.to_s).to eq "FUGA"
      end
    end

  end

  describe "#remove_entry_from_diffs" do
    let(:source_find) { [source_find1, source_find2] }
    let(:target_find) { [target_find1_changed, target_find2_changed] }
    let(:diffs) { checker.diff_entries(source_find, target_find) }

    context "remove_list is empty" do
      it "returns diffs just as it is" do
        expect(checker.remove_entry_from_diffs(diffs, [])).to eq diffs
      end
    end

    context "remove_list is not empty" do
      let(:ret) { checker.remove_entry_from_diffs(diffs, [source_entry1.path]) }
      it "removed path1 from diffs" do
        expect(ret.first.first.element.path).to eq target_entry2.path
      end
    end

  end

end
