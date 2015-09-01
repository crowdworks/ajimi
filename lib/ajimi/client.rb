module Ajimi
  class Client
    attr_accessor :checker, :reporter

    def initialize(config = {})
      @config = config
    end
    
    def check
      @checker ||= Checker.new(@config)
      @checker.check
    end

    def report(out)
      @reporter ||= Reporter.new(@checker, out)
      @reporter.report
    end
    
    def run(out = STDOUT)
      result = check
      report(out)
      result
    end
  end

end
