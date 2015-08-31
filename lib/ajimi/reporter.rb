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

        diff_files = @checker.diffs.map do |diff|
          diff.map do |change|
            change.element.path
          end
        end.flatten.uniq
        puts ""

        puts "###### diff files report ######"

        diff_files.each do |file|
          puts "--- #{@checker.source.host}: #{file}"
          puts "+++ #{@checker.target.host}: #{file}"
          puts ""
          ignore_pattern = @checker.find_contents_ignore_pattern(file)
          @checker.diff_contents(file, ignore_pattern).each do |diff|
            diff.map do |change|
              puts change.action + " " + change.position.to_s + " " + change.element.to_s
            end
          end
        end
        puts ""

        puts "###### diff summary report ######"
        puts "diff: #{diff_files.size} files"
        puts ""

        false
      end
    end

  end  
end
