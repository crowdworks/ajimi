module Ajimi
  class Checker

    def initialize(source, target, root)
      @source = source
      @target = target
      @root = root
    end
    
    def check
      source_files = @source.files(@root)
      target_files = @target.files(@root)

      source_files[0] == target_files[0]
    end

  end
end
