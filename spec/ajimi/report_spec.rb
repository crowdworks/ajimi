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
      ignored_paths: ["/path_to_ignored1", "/path_to_ignored2"],
      ignored_contents: ({"/path_to_content" => /ignored_pattern/})
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
      let(:source_file_count) { source_find.count }
      let(:target_file_count) { target_find.count }
      let(:ignored_by_path_file_count) { 0 }
      let(:pending_by_path_file_count) { 0 }
      let(:ignored_by_content_file_count) { 0 }
      let(:pending_by_content_file_count) { 0 }
      let(:uniq_diff_file_count) { 2 }

      it "print diff report" do
        allow(checker).to receive(:result).and_return(false)
        allow(checker).to receive(:diffs).and_return(diffs)
        allow(checker).to receive(:source_file_count).and_return(source_file_count)
        allow(checker).to receive(:target_file_count).and_return(target_file_count)
        allow(checker).to receive(:diff_file_count).and_return(uniq_diff_file_count)
        checker.diffs = diffs
        checker.diff_contents_cache = diff_contents_cache
        checker.enable_check_contents = true
        report_output = <<-"EOS"
###### diff entries report ######
--- source_host_value
+++ target_host_value

- 1 #{entry2.to_s}
- 2 #{entry3.to_s}
+ 1 #{entry3_changed.to_s}

###### diff contents report ######
#{diff_contents_cache}
###### diff summary report ######
source: #{source_file_count} files
target: #{target_file_count} files
ignored_by_path: #{ignored_by_path_file_count} files
pending_by_path: #{pending_by_path_file_count} files
ignored_by_content: #{ignored_by_content_file_count} files
pending_by_content: #{pending_by_content_file_count} files
diff: #{uniq_diff_file_count} files

        EOS
        expect{ reporter.report }.to output(report_output).to_stdout
      end
    end
    
  end
end
