require 'diff/lcs'

module Ajimi
  class Checker
    attr_accessor :diffs, :result, :source, :target, :ignore_list

    def initialize(config)
      @config = config.config
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
      @ignore_list = @config[:ignore_list]
    end
    
    def check
      source_find = @source.find(@check_root_path)
      target_find = @target.find(@check_root_path)

      @diffs = diff_entries(source_find, target_find, @ignore_list)
      @result = @diffs.empty?
    end

    def raw_diff_entries(source_find, target_find)
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

    def diff_entries(source_find, target_find, ignore_list = [])
      diffs = raw_diff_entries(source_find, target_find)
      diffs.map do |diff|
        diff.reject do |change|
          ignore_list.any? do |ignore|
            case ignore
            when String
              change.element.path == ignore
            when Regexp
              change.element.path.match ignore
            when Array
              change.element.path == ignore.first &&
              diff_contents(change.element.path, ignore.last).flatten.empty?
            else
              raise TypeError, "Unknown type in ignore_list"
            end
          end
        end
      end
    end

    def diff_contents(path, ignore_pattern = /$^/)
      source_file = @source.cat(path)
      target_file = @target.cat(path)
      diffs = ::Diff::LCS.diff(source_file, target_file)
      diffs.map do |diff|
        diff.reject do |change|
          change.element.match ignore_pattern
        end
      end
    end
    
    def find_contents_ignore_pattern(path)
      @ignore_list.find do |ignore|
        ignore.is_a? Array and ignore.first == path
      end.last
    end

  end
end
