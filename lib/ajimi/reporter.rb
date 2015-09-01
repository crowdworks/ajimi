module Ajimi
  class Reporter

    def initialize(checker, out = STDOUT)
      @checker = checker
      @out = out
    end

    def report
      if @checker.result
        puts "no diffs"
        true
      else
        puts "###### diff entries report ######"
        puts "--- #{@checker.source.host}"
        puts "+++ #{@checker.target.host}"
        puts ""
        @checker.diffs.each do |diff|
          diff.each do |change|
            puts change.action + " " + change.position.to_s + " " + change.element.to_s
          end
        end
        puts ""

        puts "###### diff contents report ######"
        puts @checker.diff_contents_cache
        puts ""

        puts "###### diff summary report ######"
        puts "source: #{@checker.source_file_count} files"
        puts "target: #{@checker.target_file_count} files"
        puts "ignored_by_path: #{@checker.ignored_by_path_file_count} files"
        puts "pending_by_path: #{@checker.pending_by_path_file_count} files"
        puts "ignored_by_content: #{@checker.ignored_by_content_file_count} files"
        puts "pending_by_content: #{@checker.pending_by_content_file_count} files"
        puts "diff: #{@checker.diff_file_count} files"
        puts ""

        false
      end
    end

  end  
end
