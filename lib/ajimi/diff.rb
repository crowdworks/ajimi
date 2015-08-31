require 'diff/lcs'

module Ajimi
  module Diff
    def raw_diff_entries(source_entries, target_entries)
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

    def diff_entries(source_entries, target_entries, ignore_list = [])
      diffs = Ajimi::Diff::raw_diff_entries(source_entries, target_entries)
      diffs.map do |diff|
        diff.reject do |change|
          ignore_list.any? do |ignore|
            case ignore
            when String
              change.element.path == ignore
            when Regexp
              change.element.path.match ignore
            else
              raise TypeError, "Unknown type in ignore_list"
            end
          end
        end
      end
    end

    module_function :raw_diff_entries, :diff_entries
  end
end
