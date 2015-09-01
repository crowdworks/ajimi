require 'diff/lcs'

module Ajimi
  class Checker
    attr_accessor :diffs, :result, :source, :target, :diff_contents_cache

    def initialize(config)
      @config = config
      @source = Ajimi::Server.new(
        host: @config[:source_host],
        user: @config[:source_user],
        key: @config[:source_key]
      )
      @target = Ajimi::Server.new(
        host: @config[:target_host],
        user: @config[:target_user],
        key: @config[:target_key]
      )
      @check_root_path = @config[:check_root_path]
      @ignore_paths = @config[:ignore_paths]
      @ignore_contents = @config[:ignore_contents]

    end
    
    def check
      source_find = @source.find(@check_root_path)
      target_find = @target.find(@check_root_path)

      diffs = diff_entries(source_find, target_find)
      ignored_by_path = ignore_paths(diffs, @ignore_paths)
      @diffs = remove_ignored_entry_from_diffs(diffs, ignored_by_path)
      ignored_by_contents = ignore_contents(@diffs, @ignore_contents)
      @diffs = remove_ignored_entry_from_diffs(diffs, ignored_by_contents)
      @result = @diffs.empty?
    end

    def diff_entries(source_find, target_find)
      diffs = ::Diff::LCS.diff(source_find, target_find)
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

    def ignore_paths(diffs, ignore_paths = [])
      ignored = []
      diffs.each do |diff|
        diff.each do |change|
          ignore_paths.each do |ignore|
            case ignore
            when String
              ignored << change.element.path if change.element.path == ignore
            when Regexp
              ignored << change.element.path if change.element.path.match ignore
            else
              raise TypeError, "Unknown type in ignore_paths"
            end
          end
        end
      end
      ignored.uniq.sort
    end

    def ignore_contents(diffs, ignore_contents = {})
      ignored = []
      @diff_contents_cache = ""

      diff_files = uniq_diff_file_paths(diffs)
      
      diff_files.each do |file|
        ignore_pattern = ignore_contents[file]
        diff_file_result = diff_file(file, ignore_pattern)
        if diff_file_result.flatten.empty?
          ignored << file
        else
          @diff_contents_cache << "--- #{@source.host}: #{file}\n"
          @diff_contents_cache << "+++ #{@target.host}: #{file}\n"
          @diff_contents_cache << "\n"
          diff_file_result.each do |diff|
            diff.map do |change|
              @diff_contents_cache << change.action + " " + change.position.to_s + " " + change.element.to_s + "\n"
            end
          end
        end
      end
      ignored
    end

    def uniq_diff_file_paths(diffs)
      return [] if diffs.flatten.empty?
      diff_file_paths = []
      diffs.each do |diff|
        diff.each do |change|
          diff_file_paths << change.element.path if change.element.file?
        end
      end
      diff_file_paths.uniq.sort
    end

    def diff_file(path, ignore_pattern = nil)
      source_file = @source.cat(path)
      target_file = @target.cat(path)
      diffs = ::Diff::LCS.diff(source_file, target_file)
      if ignore_pattern.nil?
        diffs
      else
        diffs.map do |diff|
          diff.reject do |change|
            change.element.match ignore_pattern
          end
        end
      end
    end

    def remove_ignored_entry_from_diffs(diffs, ignored)
      diffs.map do |diff|
        diff.reject do |change|
          ignored.include? change.element.path
        end
      end
    end

    def uniq_diff_file_count
      uniq_diff_file_paths(@diffs).count
    end

  end
end
