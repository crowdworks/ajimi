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
        @checker.diffs.each do |diff|
          diff.each do |change|
            puts change.action + " " + change.position.to_s + " " + change.element.to_s
          end
        end
        false
      end
    end

  end  
end
