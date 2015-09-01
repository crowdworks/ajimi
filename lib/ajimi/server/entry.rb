module Ajimi
  class Server
    class Entry
      attr_accessor :path, :mode, :user, :group, :bytes
      
      def initialize(params)
        @path = params[:path]
        @mode = params[:mode]
        @user = params[:user]
        @group = params[:group]
        @bytes = params[:bytes]
      end
      
      def ==(other)
        self.path == other.path &&
        self.mode == other.mode &&
        self.user == other.user &&
        self.group == other.group &&
        self.bytes == other.bytes
      end
      
      def to_s
        "#{@path}, #{@mode}, #{@user}, #{@group}, #{@bytes}"
      end

      def dir?
        @mode[0] == "d"
      end

      def file?
        @mode[0] == "-"
      end
      
      class << self
        def parse(line)
          path, mode, user, group, bytes = line.chomp.split(', ')
          Ajimi::Server::Entry.new(
            path: path,
            mode: mode,
            user: user,
            group: group,
            bytes: bytes
          )
        end
      end

    end
  end
end
