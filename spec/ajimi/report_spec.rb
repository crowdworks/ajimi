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
      let!(:diffs) { checker.diff_entries(source_entries, target_entries) }
      before { 
        checker.result = false
        checker.diffs = checker.diff_entries(source_entries, target_entries)
      }
      it "puts some diffs" do
        allow(checker).to receive(:diffs).and_return(diffs)
        allow(checker).to receive(:find_contents_ignore_pattern).and_return(//)
        allow(checker).to receive(:diff_contents).and_return([])
        report_output =
          "###### diff entries report ######\n" +
          "--- \n" +
          "+++ \n" +
          "\n" +
          "- " + "1 " + entry2.to_s + "\n" +
          "- " + "2 " + entry3.to_s + "\n" +
          "+ " + "1 " + entry3_changed.to_s + "\n" +
          "\n" +
          "###### diff files report ######\n" +
          "--- : path2\n" +
          "+++ : path2\n" +
          "\n" +
          "--- : path3\n" +
          "+++ : path3\n" +
          "\n" +
          "\n" +
          "###### diff summary report ######\n" +
          "diff: 2 files\n" +
          "\n"

        expect{ reporter.report }.to output(report_output).to_stdout
      end
    end
    
  end
end
