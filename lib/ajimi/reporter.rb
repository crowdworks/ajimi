module Ajimi
  class Reporter

    def initialize(result, out = STDOUT)
      @result = result
      @out = out
    end

    def report
      puts "no diff"
    end

  end  
end
