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
        puts "diff: #{@checker.uniq_diff_file_count} files"
        puts ""

        false
      end
    end

  end  
end
