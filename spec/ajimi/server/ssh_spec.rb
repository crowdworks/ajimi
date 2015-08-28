require 'spec_helper'

describe "Ajimi::Server::Ssh" do

  describe "#command_exec" do
    it "calls net-ssh start" do
      net_ssh = double("net-ssh")
      allow(net_ssh).to receive(:start).with("host","user",{keys: "key"})

      ssh = Ajimi::Server::Ssh.new({
        host: "host",
        user: "user",
        key: "key"
      })
      allow(ssh).to receive(:net_ssh).and_return(net_ssh)

      expect{ ssh.command_exec("echo hoge") }.not_to raise_error
    end
  end

end
