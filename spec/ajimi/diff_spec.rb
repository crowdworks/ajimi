require 'spec_helper'

describe "Ajimi::Diff" do
  let(:source_entry1) { make_entry("/root, dr-xr-x---, root, root, 4096") }
  let(:source_entry2) { make_entry("/root/.bash_history, -rw-------, root, root, 4847") }
  let(:source_entry3) { make_entry("/root/.bash_logout, -rw-r--r--, root, root, 18") }
  let(:source_entry4) { make_entry("/root/.ssh/authorized_keys, -rw-------, root, root, 1099") }

  let(:target_entry1) { make_entry("/root, dr-xr-x---, root, root, 4096") }
  let(:target_entry2) { make_entry("/root/.bash_history, -rw-------, root, root, 4847") }
  let(:target_entry3) { make_entry("/root/.bash_logout, -rw-r--r--, root, root, 18") }
  let(:target_entry3_changed) { make_entry("/root/.bash_logout, -rw-r--r--, root, root, 118") }

  describe "#raw_diff_entries" do

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

  describe "#diff_entries" do
    context "when ignore list is empty" do
      let(:source_entries) { [source_entry1] }
      let(:target_entries) { [target_entry1, target_entry2] }
      let(:ignore_list) { [] }
      let(:diffs) { Ajimi::Diff.diff_entries(source_entries, target_entries, ignore_list) }

      it "has + entry" do
        expect(diffs.first.first.action).to eq "+"
        expect(diffs.first.first.element).to eq target_entry2
      end
    end

    context "when ignore list has strings" do
      let(:source_entries) { [source_entry1, source_entry3] }
      let(:target_entries) { [target_entry1, target_entry2, target_entry3_changed] }
      let(:ignore_list) { ["/hoge", "/root/.bash_logout"] }
      let(:diffs) { Ajimi::Diff.diff_entries(source_entries, target_entries, ignore_list) }

      it "filters ignore_list" do
        expect(diffs.first.size).to eq 1
        expect(diffs.first.first.action).to eq "+"
        expect(diffs.first.first.element).to eq target_entry2
      end
    end

    context "when ignore list has regexp" do
      let(:source_entries) { [source_entry1, source_entry3, source_entry4] }
      let(:target_entries) { [target_entry1, target_entry2, target_entry3_changed] }
      let(:ignore_list) { [%r|\A/root/\.bash.*|] }
      let(:diffs) { Ajimi::Diff.diff_entries(source_entries, target_entries, ignore_list) }

      it "filters ignore_list" do
        expect(diffs.first.size).to eq 1
        expect(diffs.first.first.action).to eq "-"
        expect(diffs.first.first.element).to eq source_entry4
      end
    end

  end
end
