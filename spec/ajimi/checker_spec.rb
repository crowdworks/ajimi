require 'spec_helper'

describe Ajimi::Checker do
  let(:source) { Ajimi::Server.new }
  let(:target) { Ajimi::Server.new }
  let(:config) { {
    source_host: "source_host_value",
    source_user: "source_user_value",
    source_key: "source_key_value",
    target_host: "target_host_value",
    target_user: "target_user_value",
    target_key: "target_key_value",
    check_root_path: "check_root_path_value",
    ignore_paths: ["/path_to_ignore1", "/path_to_ignore2"],
    ignore_contents: ({"/path_to_content" => /ignore_pattern/})
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

  describe "#ignore_paths" do
    let(:diffs) { checker.diff_entries(source_find, target_find) }
    let(:ignored) { checker.ignore_paths(diffs, ignore_paths) }
    context "when ignore_paths is empty" do
      let(:source_find) { [source_find1] }
      let(:target_find) { [target_find1, target_find2] }
      let(:ignore_paths) { [] }

      it "return empty list" do
        expect(ignored.empty?).to eq true
      end
    end

    context "when ignore list has strings" do
      let(:source_find) { [source_find1, source_find3] }
      let(:target_find) { [target_find1, target_find2, target_find3_changed] }
      let(:ignore_paths) { ["/hoge", "/root/.bash_logout"] }

      it "returns ignored list using ==" do
        expect(ignored).to eq ["/root/.bash_logout"]
      end
    end

    context "when ignore list has regexp" do
      let(:source_find) { [source_find1, source_find3, source_find4] }
      let(:target_find) { [target_find1, target_find2, target_find3_changed] }
      let(:ignore_paths) { [%r|\A/root/\.bash.*|] }

      it "returns ignored list using match" do
        expect(ignored).to eq ["/root/.bash_history", "/root/.bash_logout"]
      end
    end

    context "when ignore list has unknown type" do
      let(:source_find) { [source_find1, source_find3, source_find4] }
      let(:target_find) { [target_find1, target_find2, target_find3_changed] }
      let(:ignore_paths) { [1, 2, 3] }

      it "raise_error TypeError" do
        expect{ checker.ignore_paths(diffs, ignore_paths) }.to raise_error(TypeError)
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
