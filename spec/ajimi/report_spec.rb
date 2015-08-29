require 'spec_helper'

describe "Ajimi::Reporter" do
  describe "#report" do
    let(:checker) { Ajimi::Checker.new(Ajimi::Server.new, Ajimi::Server.new, "/") }
    let(:reporter) { Ajimi::Reporter.new(checker) }
    context "when target is the same as source" do
      before { checker.result = true }
      it "puts no diffs" do
        expect{ reporter.report }.to output("no diffs\n").to_stdout
      end
    end

    context "when target differs from source" do
      let(:entry1) { make_entry("path1, mode1, user1, group1, bytes1") }
      let(:entry2) { make_entry("path2, mode2, user2, group2, bytes2") }
      let(:entry3) { make_entry("path3, mode3, user3, group3, bytes3") }
      let(:entry3_changed) { make_entry("path3, mode3, user3, group3, bytes3_changed") }
      let(:source_entries) { [entry1, entry2, entry3] }
      let(:target_entries) { [entry1, entry3_changed] }
      let!(:diffs) { Ajimi::Diff.diff_entries(source_entries, target_entries) }
      before { 
        checker.result = false
        checker.diffs = Ajimi::Diff.diff_entries(source_entries, target_entries)
      }
      it "puts some diffs" do
        allow(checker).to receive(:diffs).and_return(diffs)
        report_output =
          "- " + entry2.to_s + "\n" +
          "- " + entry3.to_s + "\n" +
          "+ " + entry3_changed.to_s + "\n"
        expect{ reporter.report }.to output(report_output).to_stdout
      end
    end
    
  end
end
