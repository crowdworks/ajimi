require 'ajimi/server/ssh'
require 'ajimi/server/entry'

module Ajimi
  class Server
    def initialize(options = {})
      @options = options
    end

    def host
      @options[:host]
    end

    def backend
      @backend ||= Ajimi::Server::Ssh.new(@options)
    end

    def command_exec(cmd)
      backend.command_exec(cmd)
    end
    
    def find(dir)
      stdout = command_exec("sudo find #{dir} -ls | awk  '{printf \"%s, %s, %s, %s, %s\\n\", \$11, \$3, \$5, \$6, \$7}'")
      stdout.split(/\n/).map {|line| line.chomp }.sort
    end

    def entries(dir)
      @entries ||= find(dir).map{ |line| Ajimi::Server::Entry.parse(line) }
    end

    def cat(file)
      stdout = command_exec("sudo cat #{file}")
      stdout.split(/\n/).map {|line| line.chomp }
    end

  end
end
