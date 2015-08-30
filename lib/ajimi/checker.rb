require 'ajimi/diff'

module Ajimi
  class Checker
    include Ajimi::Diff

    attr_accessor :diffs, :result

    def initialize(source, target, check_root_path)
      @source = source
      @target = target
      @check_root_path = check_root_path
    end
    
    def check
      source_entries = @source.entries(@check_root_path)
      target_entries = @target.entries(@check_root_path)

      @diffs = diff_entries(source_entries, target_entries)
      @result = @diffs.empty?
    end

  end
end
