require 'diff/lcs'

module Ajimi
  module Diff
    def diff_entries(source_entries, target_entries)
      diffs = ::Diff::LCS.diff(source_entries.map(&:to_s), target_entries.map(&:to_s))
      diffs.map do |diff|
        diff.map do |change|
          ::Diff::LCS::Change.new(
            change.action,
            change.position,
            Ajimi::Server::Entry.parse(change.element)
          )
        end
      end
    end

    module_function :diff_entries
  end
end
