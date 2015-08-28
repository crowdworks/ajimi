module Ajimi
  class Checker

    def initialize(server1, server2)
      @server1 = server1
      @server2 = server2
    end
    
    def check
      @server1.data == @server2.data
    end

  end
end
