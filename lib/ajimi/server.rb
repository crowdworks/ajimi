module Ajimi
  class Server
    def initialize(options)
      @host = options[:host]
      @user = options[:user]
      @key = options[:key]
    end
    
    def data(dummy = nil)
      @data ||= dummy
    end
  end
end
