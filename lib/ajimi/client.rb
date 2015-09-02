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

    desc "all", "check and report"
    def all(out = STDOUT)
      result = check
      report(out)
      result
    end
  end

end
