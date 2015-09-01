require 'spec_helper'

describe "Ajimi::Reporter" do
  describe "#report" do
    let(:checker) { Ajimi::Checker.new(Ajimi::Config.new) }
    let(:reporter) { Ajimi::Reporter.new(checker) }
    context "when target is the same as source" do
      before { checker.result = true }
      it "puts no diffs" do
        expect{ reporter.report }.to output("no diffs\n").to_stdout
      end
    end

    context "when target differs from source" do
      let(:entry1) { "path1, mode1, user1, group1, bytes1" }
      let(:entry2) { "path2, mode2, user2, group2, bytes2" }
      let(:entry3) { "path3, mode3, user3, group3, bytes3" }
      let(:entry3_changed) { "path3, mode3, user3, group3, bytes3_changed" }
      let(:source_find) { [entry1, entry2, entry3] }
      let(:target_find) { [entry1, entry3_changed] }
      let(:diffs) { checker.diff_entries(source_find, target_find) }
      it "print diff report" do
        allow(checker).to receive(:result).and_return(false)
        allow(checker).to receive(:diffs).and_return(diffs)
        allow(checker).to receive(:find_contents_ignore_pattern)
        allow(checker).to receive(:diff_contents).with("path2", nil).and_return([
          [ make_change("-", 1, "hoge") ]
        ])
        allow(checker).to receive(:diff_contents).with("path3", nil).and_return([
          [ make_change("-", 1, "HOGE"),
            make_change("+", 1, "FUGA") ]
        ])

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
          "- 1 hoge\n" +
          "--- : path3\n" +
          "+++ : path3\n" +
          "\n" +
          "- 1 HOGE\n" +
          "+ 1 FUGA\n" +
          "\n" +
          "###### diff summary report ######\n" +
          "diff: 2 files\n" +
          "\n"

        expect{ reporter.report }.to output(report_output).to_stdout
      end
    end
    
  end
end
