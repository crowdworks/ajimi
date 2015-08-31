require 'spec_helper'

describe Ajimi::Checker do
  describe "#check" do
    let(:source) { Ajimi::Server.new }
    let(:target) { Ajimi::Server.new }
    let(:checker) { Ajimi::Checker.new(source, target, "/") }
    let(:entry1) { make_entry("path1, mode1, user1, group1, bytes1") }
    let(:entry2) { make_entry("path2, mode2, user2, group2, bytes2") }
    let(:entry2_changed) { make_entry("path2, mode2, user2, group2, bytes2_changed") }

    context "when 2 servers have same entries" do
      it "returns true" do
        allow(source).to receive(:entries).and_return([entry1, entry2])
        allow(target).to receive(:entries).and_return([entry1, entry2])
        expect(checker.check).to be true
      end
    end

    context "when 2 servers have different entries" do
      it "returns false" do
        allow(source).to receive(:entries).and_return([entry1, entry2])
        allow(target).to receive(:entries).and_return([entry1, entry2_changed])
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
end
