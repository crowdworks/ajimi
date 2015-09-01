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

    def source_host(host)
      @config[:source_host] = host
    end

    def source_user(user)
      @config[:source_user] = user
    end

    def source_key(key)
      @config[:source_key] = key
    end

    def target_host(host)
      @config[:target_host] = host
    end

    def target_user(user)
      @config[:target_user] = user
    end

    def target_key(key)
      @config[:target_key] = key
    end

    def check_root_path(path)
      @config[:check_root_path] = path
    end

    def ignore_paths(array)
      @config[:ignore_paths] = array
    end

    def ignore_contents(hash)
      @config[:ignore_contents] = hash
    end

  end
end
