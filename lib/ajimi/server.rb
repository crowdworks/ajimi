require 'ajimi/server/ssh'
require 'ajimi/server/entry'

module Ajimi
  class Server

    def initialize(name, **options)
      @name = name
      @options = options
      @options[:ssh_options] = options[:ssh_options] || {}
      @options[:ssh_options][:host] = options[:ssh_options][:host] || @name
    end

    def ==(other)
      self.instance_variable_get(:@name) == other.instance_variable_get(:@name)
      self.instance_variable_get(:@options) == other.instance_variable_get(:@options)
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
    
    def find(dir, find_max_depth = nil, pruned_paths = [], enable_nice = nil)
      enable_nice = @options[:enable_nice] if enable_nice.nil?
      cmd = build_find_cmd(dir, find_max_depth, pruned_paths, enable_nice)
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

    private

    def build_find_cmd(dir, find_max_depth  = nil, pruned_paths = [], enable_nice = false)
      cmd = "sudo"
      cmd += " nice -n 19 ionice -c 3" if enable_nice
      cmd += " find #{dir} -ls"
      cmd += " -maxdepth #{find_max_depth}" if find_max_depth
      cmd += build_pruned_paths_option(pruned_paths)
      cmd += " | awk  '{printf \"%s, %s, %s, %s, %s\\n\", \$11, \$3, \$5, \$6, \$7}'"
    end

    def build_pruned_paths_option(pruned_paths = [])
      return "" if pruned_paths.empty?
      pruned_paths.map{ |path| " -path #{path} -prune" }.join(" -o")
    end

  end
end
