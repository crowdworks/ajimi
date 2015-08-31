require 'net/ssh'

module Ajimi
  class Server
    class Ssh
      def initialize(options = {})
        @host = options[:host]
        @user = options[:user]
        @key = options[:key]
      end

      def net_ssh
        Net::SSH
      end
      
      def command_exec(cmd)
        ssh_options_default = {}
        ssh_options_override = {
          keys: @key
        }
        ssh_options = ssh_options_default.merge(ssh_options_override)

        stdout = ""
        stderr = ""
        net_ssh.start(@host, @user, ssh_options) do |session|
          session.exec!(cmd) do |channel, stream, data|
            stdout << data if stream == :stdout
            stderr << data if stream == :stderr
          end
        end
        stdout
      end

    end
  end
end
