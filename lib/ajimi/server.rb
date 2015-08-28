require 'ajimi/server/ssh'
require 'ajimi/server/file'

module Ajimi
  class Server
    def initialize(options = {})
      @options = options
    end
    
    def backend
      @backend ||= Ajimi::Server::Ssh.new(@options)
    end

    def command_exec(cmd)
      backend.command_exec(cmd)
    end
    
    def find(dir)
      stdout = command_exec("sudo find #{dir} -ls | awk  '{printf \"%s, %s, %s, %s, %s\\n\", \$11, \$3, \$5, \$6, \$7}'")
      stdout.split(/\n/).map {|line| line.chomp }
    end

    def files(dir)
      @files ||= find(dir).map{ |line| Ajimi::Server::File.parse(line) }
    end

  end
end
