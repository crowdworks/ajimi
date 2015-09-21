module Ajimi
  class Config

    attr_accessor :config

    def initialize
      @config = {}
    end

    def self.load(path)
      Ajimi::Config.new.tap do |obj|
        obj.load_file(path)
      end.config
    end

    def load_file(path)
      instance_eval(File.read(path), path) if path
    end

    CONFIG_KEYWORDS = %i(
      source
      target
      check_root_path
      ignored_paths
      ignored_contents
      pending_paths
      pending_contents
    )

    CONFIG_KEYWORDS.each do |keyword|
      define_method(keyword) do |params, options = nil|
        if options.nil?
          @config[keyword] = params
        else
          @config[keyword] = { name: params }.merge(options)
        end
      end
    end

  end
end
