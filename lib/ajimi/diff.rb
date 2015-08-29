require 'diff/lcs'

module Ajimi
  module Diff
    def diff_entries(source_entries, target_entries)
      diffs = ::Diff::LCS.diff(source_entries, target_entries)
    end

    module_function :diff_entries
  end
end
