require "ajimi/version"
require 'ajimi/checker'
require 'ajimi/reporter'
require 'ajimi/server'

module Ajimi
  class Controller
    def check
      @server1 = Ajimi::Server.new(
        host: "server1.example.com",
        user: "minamijoyo",
        key: "~/.ssh/id_rsa"
      )
      @server2 = Ajimi::Server.new(
        host: "server2.example.com",
        user: "minamijoyo",
        key: "~/.ssh/id_rsa"
      )
      
      @server1.data("hoge")
      @server2.data("hoge")
      @checker = Checker.new(@server1,@server2)
      result = @checker.check
    end
    
    def run(out = STDOUT)
      result = check
      @reporter = Reporter.new(result, out)
      @reporter.report
    end
  end

end
