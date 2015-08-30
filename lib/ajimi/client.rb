module Ajimi
  class Client
    attr_accessor :checker, :reporter

    def initialize
      @source = Ajimi::Server.new(
        host: "sandbox-app03b",
        user: "morita",
        key: "~/.ssh/id_rsa"
      )
      @target = Ajimi::Server.new(
        host: "sandbox-webapp",
        user: "ec2-user",
        key: "~/.ssh/MasayukiMORITA.pem"
      )
      @root = "/root"
    end
    
    def check
      @checker ||= Checker.new(@source, @target, @root)
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
