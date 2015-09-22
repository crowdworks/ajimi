require 'erb'

module Ajimi
  class Reporter

    def initialize(checker, report_template_path = nil)
      @checker = checker
      @report_template_path = report_template_path || File.expand_path('../reporter/template.erb', __FILE__)
    end

    def report
      if @checker.result
        puts "no diffs"
        true
      else
        erb = File.read(@report_template_path)
        puts ERB.new(erb, nil, '-').result(binding)
        false
      end
    end

  end  
end
