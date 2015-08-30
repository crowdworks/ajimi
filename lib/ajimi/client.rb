module Ajimi
  class Client
    attr_accessor :checker, :reporter

    def initialize(config = {})
      @config = config
      @source = Ajimi::Server.new(
        host: @config[:source_host],
        user: @config[:source_user],
        key: @config[:source_key]
      )
      @target = Ajimi::Server.new(
        host: @config[:target_host],
        user: @config[:target_user],
        key: @config[:target_key]
      )
      @check_root_path = @config[:check_root_path]
    end
    
    def check
      @checker ||= Checker.new(@source, @target, @check_root_path)
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
