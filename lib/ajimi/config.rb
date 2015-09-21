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
      source_host
      source_user
      source_key
      target_host
      target_user
      target_key
      check_root_path
      ignored_paths
      ignored_contents
      pending_paths
      pending_contents
    )

    CONFIG_KEYWORDS.each do |keyword|
      define_method(keyword) { |param| @config[keyword] = param }
    end

  end
end
