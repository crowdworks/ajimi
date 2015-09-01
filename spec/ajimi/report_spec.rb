require 'spec_helper'

describe "Ajimi::Reporter" do
  describe "#report" do
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
      let(:diff_contents_cache) {
        "--- : path2\n" +
        "+++ : path2\n" +
        "\n" +
        "- 1 hoge\n" +
        "--- : path3\n" +
        "+++ : path3\n" +
        "\n" +
        "- 1 HOGE\n" +
        "+ 1 FUGA\n"
      }
      let(:uniq_diff_file_count) { 2 }

      it "print diff report" do
        allow(checker).to receive(:result).and_return(false)
        allow(checker).to receive(:diffs).and_return(diffs)
        allow(checker).to receive(:uniq_diff_file_count).and_return(uniq_diff_file_count)
        checker.diffs = diffs
        checker.diff_contents_cache = diff_contents_cache
        report_output =
          "###### diff entries report ######\n" +
          "--- source_host_value\n" +
          "+++ target_host_value\n" +
          "\n" +
          "- " + "1 " + entry2.to_s + "\n" +
          "- " + "2 " + entry3.to_s + "\n" +
          "+ " + "1 " + entry3_changed.to_s + "\n" +
          "\n" +
          "###### diff contents report ######\n" +
          diff_contents_cache +
          "\n" +
          "###### diff summary report ######\n" +
          "diff: #{uniq_diff_file_count} files\n" +
          "\n"

        expect{ reporter.report }.to output(report_output).to_stdout
      end
    end
    
  end
end
