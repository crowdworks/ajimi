require 'thor'

module Ajimi
  class Client < Thor
    attr_accessor :checker, :reporter

    class_option :ajimifile, :default => './Ajimifile', :desc => "Ajimifile path"
    class_option :verbose, :type => :boolean, :default => true

    def initialize(*args)
      super
      @config = Ajimi::Config.load(options[:ajimifile])
      @config[:verbose] = options[:verbose] unless options[:verbose].nil?
    end

    desc "check", "diff source and target servers"
    option :check_root_path, :type => :string
    option :find_max_depth, :type => :numeric
    option :enable_check_contents, :type => :boolean, :default => false
    option :limit_check_contents, :type => :numeric, :default => 0
    def check
      @config.merge!( {
        find_max_depth: options[:find_max_depth],
        enable_check_contents: options[:enable_check_contents],
        limit_check_contents: options[:limit_check_contents]
      } )
      @config[:check_root_path] = options[:check_root_path] if options[:check_root_path]
      _check
    end

    desc "dir <path>", "diff specified directroy"
    option :find_max_depth, :type => :numeric, :default => 1
    option :ignored_pattern, :type => :string
    def dir(path)
      @config.merge!( {
        check_root_path: path,
        find_max_depth: options[:find_max_depth],
        enable_check_contents: false
      } )
      @config[:ignored_paths] << Regexp.new(options[:ignored_pattern]) if options[:ignored_pattern]

      _check
    end

    desc "file <path>", "diff specified file"
    option :ignored_pattern, :type => :string
    def file(path)
      @config.merge!( {
        check_root_path: path,
        enable_check_contents: true
      } )
      @config[:ignored_contents].merge!( { path => Regexp.new(options[:ignored_pattern]) } ) if options[:ignored_pattern]

      _check
    end
    
    desc "exec source|target <command>", "execute arbitrary command at source or target"
    def exec(server, command)
      raise ArgumentError, "server option must be source or target" unless %w(source target).include? server 

      @server = Ajimi::Server.new(@config[server.to_sym])
      puts "Execute command at #{server}_host: #{@server.host}\n"
      stdout = @server.command_exec(command)
      puts "#{stdout}"
      puts "\n"
    end

    private
    
    def _check
      @checker ||= Checker.new(@config)
      result = @checker.check

      @reporter ||= Reporter.new(@checker)
      @reporter.report
      result
    end
    
  end

end
