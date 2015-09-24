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

  end

  describe "#filter_path" do
    context "when pattern is String" do
      it "returns path if matched" do
        expect(checker.filter_path("/root", "/root")).to eq "/root"
      end

      it "returns nil if not matched" do
        expect(checker.filter_path("/root/.bash_history", "/root")).to eq nil
      end
    end

    context "when pattern is Regexp" do
      it "returns path if matched" do
        expect(checker.filter_path("/root/.bash_history", %r|^/root|)).to eq "/root/.bash_history"
      end

      it "returns nil if not matched" do
        expect(checker.filter_path("/root/.bash_history", %r|^/root$|)).to eq nil
      end
    end

    context "when pattern is unknown type" do
      it "raises TypeError" do
        expect{ checker.filter_path("/root", 1) }.to raise_error(TypeError)
      end
    end

  end

  describe "#uniq_diff_file_paths" do
      let(:source_find) { [source_find1, source_find2, source_find3] }
      let(:target_find) { [target_find1_changed, target_find2_changed, target_find3_changed] }
      let(:diffs) { checker.diff_entries(source_find, target_find) }
      let(:file_paths) { checker.uniq_diff_file_paths(diffs) }

      it "returns differed file paths" do
        expect(file_paths).to eq ["/root/.bash_history", "/root/.bash_logout"]
      end

      it "returns uniq Array" do
        expect(file_paths.uniq).to eq file_paths
      end

      it "does not included dir" do
        expect(file_paths).not_to include "/root" 
      end

  end

end
