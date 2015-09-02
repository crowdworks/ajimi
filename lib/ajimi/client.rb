require 'thor'

module Ajimi
  class Client < Thor
    attr_accessor :checker, :reporter

    class_option :ajimifile, :default => './Ajimifile', :desc => "Ajimifile path"

    def initialize(*args)
      super
      @config = Ajimi::Config.load(options[:ajimifile])
    end

    desc "check", "check diff"
    def check
      @checker ||= Checker.new(@config)
      @checker.check
    end

    desc "report", "print report"
    def report(out)
      @reporter ||= Reporter.new(@checker, out)
      @reporter.report
    end

    desc "exec source|target command", "execute arbitrary command at source or target"
    def exec(server, command)
      raise ArgumentError, "server option must be source or target" if %w(source target).include? options[:server] 

      @server = Ajimi::Server.new(
        host: @config["#{server}_host".to_sym],
        user: @config["#{server}_user".to_sym],
        key: @config["#{server}_key".to_sym]
      )
      puts "Execute command at #{server}_host: #{@config["#{server}_host".to_sym]}\n"
      stdout = @server.command_exec(command)
      puts "#{stdout}"
      puts "\n"
    end

    desc "all", "check and report"
    def all(out = STDOUT)
      result = check
      report(out)
      result
    end
  end

end
