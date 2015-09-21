require 'ajimi/server/ssh'
require 'ajimi/server/entry'

module Ajimi
  class Server

    def initialize(name, options = {})
      @name = name
      @options = options
      @options[:ssh_options] = options[:ssh_options] || {}
      @options[:ssh_options][:host] = options[:ssh_options][:host] || name
    end

    def host
      @options[:ssh_options][:host]
    end

    def backend
      @backend ||= Ajimi::Server::Ssh.new(@options[:ssh_options])
    end

    def command_exec(cmd)
      backend.command_exec(cmd)
    end
    
    def find(dir, find_max_depth = nil)
      cmd = "sudo find #{dir} -ls"
      cmd += " -maxdepth #{find_max_depth}" if find_max_depth
      cmd += " -path /dev -prune -o -path /proc -prune"
      cmd += " | awk  '{printf \"%s, %s, %s, %s, %s\\n\", \$11, \$3, \$5, \$6, \$7}'"
      stdout = command_exec(cmd)
      stdout.split(/\n/).map {|line| line.chomp }.sort
    end

    def entries(dir)
      @entries ||= find(dir).map{ |line| Ajimi::Server::Entry.parse(line) }
    end

    def cat(file)
      stdout = command_exec("sudo cat #{file}")
      stdout.split(/\n/).map {|line| line.chomp }
    end

    def cat_or_md5sum(file)
      stdout = command_exec("if (sudo file -b #{file} | grep text > /dev/null 2>&1) ; then (sudo cat #{file}) else (sudo md5sum #{file}) fi")
      stdout.split(/\n/).map {|line| line.chomp }
    end

  end
end
