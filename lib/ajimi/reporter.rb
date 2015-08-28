module Ajimi
  class Reporter

    def initialize(result, out = STDOUT)
      @result = result
      @out = out
    end

    def report
      if @result
        puts "no diff"
      else
        puts "some diff"
      end
    end

  end  
end
