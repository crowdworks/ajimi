module Ajimi
  class Checker

    def initialize(source, target, root)
      @source = source
      @target = target
      @root = root
    end
    
    def check
      source_entries = @source.entries(@root)
      target_entries = @target.entries(@root)

      source_entries[0] == target_entries[0]
    end

  end
end
