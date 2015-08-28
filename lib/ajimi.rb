require "ajimi/version"
require 'ajimi/checker'
require 'ajimi/reporter'
require 'ajimi/server'

module Ajimi
  class Client
    def check
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
      @checker = Checker.new(@source, @target, @root)
      result = @checker.check
    end
    
    def run(out = STDOUT)
      result = check
      @reporter = Reporter.new(result, out)
      @reporter.report
    end
  end

end
