require 'diff/lcs'

module Ajimi
  class Checker
    attr_accessor :diffs, :result, :source, :target, :diff_contents_cache, :enable_check_contents

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
      @ignore_paths = @config[:ignore_paths] || []
      @ignore_contents = @config[:ignore_contents] || {}
      @pending_paths = @config[:pending_paths] || []
      @pending_contents = @config[:pending_contents] || {}
      @enable_check_contents = @config[:enable_check_contents] || false
      @limit_check_contents = @config[:limit_check_contents] || 0
      @find_max_depth = @config[:find_max_depth]
      @verbose = @config[:verbose] || false
    end
    
    def check
      puts_verbose "Start ajimi check with options: #{@config}\n"

      puts_verbose "Finding...: #{@config[:source_host]}\n"
      @source_find = @source.find(@check_root_path, @find_max_depth)

      puts_verbose "Finding...: #{@config[:target_host]}\n"
      @target_find = @target.find(@check_root_path, @find_max_depth)

      puts_verbose "Checking diff entries...\n"
      @diffs = diff_entries(@source_find, @target_find)

      puts_verbose "Checking ignore_paths and pending_paths...\n"
      @diffs = ignore_and_pending_paths(@diffs, @ignore_paths, @pending_paths)

      if @enable_check_contents
        puts_verbose "Checking ignore_contents and pending_contents...\n"
        @diffs = ignore_and_pending_contents(@diffs, @ignore_contents, @pending_contents, @limit_check_contents)
      end

      puts_verbose "Diffs empty?: #{@diffs.empty?}\n"
      puts_verbose "\n"

      @result = @diffs.empty?
    end

    def puts_verbose(message)
      puts message if @config[:verbose]
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

    def ignore_and_pending_paths(diffs, ignore_paths, pending_paths)
      if !ignore_paths.empty?
        @ignored_by_path = filter_paths(diffs, ignore_paths)
        diffs = remove_entry_from_diffs(diffs, @ignored_by_path)
      end
      
      if !pending_paths.empty?
        @pending_by_path = filter_paths(diffs, pending_paths)
        diffs = remove_entry_from_diffs(diffs, @pending_by_path)
      end
      diffs
    end

    def filter_paths(diffs, filter_paths = [])
      filtered = []
      diffs.each do |diff|
        diff.each do |change|
          filter_paths.each do |pattern|
            case pattern
            when String
              filtered << change.element.path if change.element.path == pattern
            when Regexp
              filtered << change.element.path if change.element.path.match pattern
            else
              raise TypeError, "Unknown type in ignore_paths"
            end
          end
        end
      end
      filtered.uniq.sort
    end

    def ignore_and_pending_contents(diffs, ignore_contents, pending_contents, limit_check_contents)
      @ignored_by_content = []
      @pending_by_content = []
      @diff_contents_cache = ""
  
      diff_files = product_set_file_paths(diffs)
      diff_files = diff_files.slice(0, limit_check_contents) if limit_check_contents > 0
      diff_files.each do |file|
        diff_file_result = diff_file(file)
        ignored_diff_file_result = filter_diff_file(diff_file_result, ignore_contents[file])
        if ignored_diff_file_result.flatten.empty?
          @ignored_by_content << file
        else
          pending_diff_file_result = filter_diff_file(ignored_diff_file_result, pending_contents[file])
          if pending_diff_file_result.flatten.empty?
            @pending_by_content << file
          else
            @diff_contents_cache << "--- #{@source.host}: #{file}\n"
            @diff_contents_cache << "+++ #{@target.host}: #{file}\n"
            @diff_contents_cache << "\n"
            pending_diff_file_result.each do |diff|
              diff.map do |change|
                @diff_contents_cache << change.action + " " + change.position.to_s + " " + change.element.to_s + "\n"
              end
            end
          end
        end
      end
      diffs = remove_entry_from_diffs(diffs, @ignored_by_content + @pending_by_content)
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

    def split_diff_file_paths(diffs)
      return [],[] if diffs.flatten.empty?
      minus = []
      plus = []
      diffs.each do |diff|
        diff.each do |change|
          minus << change.element.path if change.action == "-" && change.element.file?
          plus << change.element.path if change.action == "+" && change.element.file?
        end
      end
      return minus, plus
    end
    
    def union_set_diff_file_paths(diffs)
      minus, plus = split_diff_file_paths(diffs)
      (minus | plus).sort
    end

    def product_set_file_paths(diffs)
      minus, plus = split_diff_file_paths(diffs)
      (minus & plus).sort
    end

    def diff_file(path)
      source_file = @source.cat(path)
      target_file = @target.cat(path)
      diffs = ::Diff::LCS.diff(source_file, target_file)
    end

    def filter_diff_file(diffs, filter_pattern = nil)
      if filter_pattern.nil?
        diffs
      else
        diffs.map do |diff|
          diff.reject do |change|
            change.element.match filter_pattern
          end
        end
      end
    end

    def remove_entry_from_diffs(diffs, remove_list)
      diffs.map do |diff|
        diff.reject do |change|
          remove_list.include? change.element.path
        end
      end
    end

    def source_file_count
      @source_find ? @source_find.count : 0
    end

    def target_file_count
      @target_find ? @target_find.count : 0
    end
    
    def ignored_by_path_file_count
      @ignored_by_path ? @ignored_by_path.count : 0
    end

    def pending_by_path_file_count
      @pending_by_path ? @pending_by_path.count : 0
    end

    def ignored_by_content_file_count
      @ignored_by_content ? @ignored_by_content.count : 0
    end

    def pending_by_content_file_count
      @pending_by_content ? @pending_by_content.count : 0
    end

    def diff_file_count
      union_set_diff_file_paths(@diffs).count
    end

  end
end
