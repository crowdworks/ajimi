require 'spec_helper'

describe "Ajimi::Diff" do
  
  describe "#diff_entries" do
    let(:source_entry1) { make_entry("/root, dr-xr-x---, root, root, 4096") }
    let(:source_entry2) { make_entry("/root/.bash_history, -rw-------, root, root, 4847") }
    let(:source_entry3) { make_entry("/root/.bash_logout, -rw-r--r--, root, root, 18") }

    let(:target_entry1) { make_entry("/root, dr-xr-x---, root, root, 4096") }
    let(:target_entry2) { make_entry("/root/.bash_history, -rw-------, root, root, 4847") }
    let(:target_entry3) { make_entry("/root/.bash_logout, -rw-r--r--, root, root, 18") }
    let(:target_entry3_changed) { make_entry("/root/.bash_logout, -rw-r--r--, root, root, 118") }

    let(:diffs) { Ajimi::Diff.diff_entries(source_entries, target_entries) }

    context "when source and target have same entry" do
      let(:source_entries) { [source_entry1, source_entry2, source_entry3] }
      let(:target_entries) { [target_entry1, target_entry2, target_entry3] }

      it "has empty list" do
        expect(diffs.empty?).to be true
      end
    end
    
    context "when target has entry2" do
      let(:source_entries) { [source_entry1] }
      let(:target_entries) { [target_entry1, target_entry2] }

      it "has + entry" do
        expect(diffs.first.first.action).to eq "+"
        expect(diffs.first.first.element).to eq target_entry2
      end
    end

    context "when target does not have entry2" do
      let(:source_entries) { [source_entry1, source_entry2, source_entry3] }
      let(:target_entries) { [target_entry1, target_entry3] }

      it "has - entry" do
        expect(diffs.first.first.action).to eq "-"
        expect(diffs.first.first.element).to eq source_entry2
      end
    end

    context "when entry3 has changed" do
      let(:source_entries) { [source_entry1, source_entry3] }
      let(:target_entries) { [target_entry1, target_entry3_changed] }

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
end
