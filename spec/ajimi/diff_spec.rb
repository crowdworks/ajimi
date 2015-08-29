require 'spec_helper'

describe "Ajimi::Diff" do
  
  describe "#entries" do
    let(:entry1) { Ajimi::Server::Entry.parse("path1, mode1, user1, group1, bytes1") }
    let(:entry2) { Ajimi::Server::Entry.parse("path2, mode2, user2, group2, bytes2") }
    let(:entry3) { Ajimi::Server::Entry.parse("path3, mode3, user3, group3, bytes3") }
    let(:entry3_changed) { Ajimi::Server::Entry.parse("path3, mode3, user3, group3, bytes3_changed") }

    let(:diffs) { Ajimi::Diff.diff_entries(source_entries, target_entries) }

    context "when source and target have same entry" do
      let(:source_entries) { [entry1] }
      let(:target_entries) { [entry1] }

      it "has empty list" do
        expect(diffs.empty?).to be true
      end
    end
    
    context "when target has entry2" do
      let(:source_entries) { [entry1] }
      let(:target_entries) { [entry1, entry2] }

      it "has + entry" do
        expect(diffs.first.first.action).to eq "+"
        expect(diffs.first.first.element).to eq entry2
      end
    end

    context "when target does not have entry3" do
      let(:source_entries) { [entry1, entry3] }
      let(:target_entries) { [entry1] }

      it "has - entry" do
        expect(diffs.first.first.action).to eq "-"
        expect(diffs.first.first.element).to eq entry3
      end
    end

    context "when entry3 has changed" do
      let(:source_entries) { [entry1, entry3] }
      let(:target_entries) { [entry1, entry3_changed] }

      it "has - entry" do
        expect(diffs.first.first.action).to eq "-"
        expect(diffs.first.first.element).to eq entry3
      end
      it "has + entry" do
        expect(diffs.first.last.action).to eq "+"
        expect(diffs.first.last.element).to eq entry3_changed
      end

    end

  end
end
