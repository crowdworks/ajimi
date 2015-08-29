require 'spec_helper'

describe "Ajimi::Server" do
  let(:dummy_response) {
    "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705\n" +
    "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096\n"
  }
  let(:find_return) { [
    "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096",
    "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705",
  ] }
  let(:server) { Ajimi::Server.new }

  describe "#find" do
    it "returns sorted Array of line" do
      backend_mock = double('dummy backend')
      expect(backend_mock).to receive(:command_exec).and_return(dummy_response)
      allow(server).to receive(:backend).and_return(backend_mock)
      expect(server.find("/home/ec2-user")).to eq find_return
    end
  end
  
  describe "#entries" do
    it "return parsed entries" do
      allow(server).to receive(:find).and_return(find_return)
      entries = server.entries("/home/ec2-user")
      expect(entries[0].path).to eq "/home/ec2-user"
      expect(entries[1].path).to eq "/home/ec2-user/.bash_history"

    end
  end
  
  describe "#command_exec" do
    it "returns command stdout" do
      backend_mock = double('dummy backend')
      expect(backend_mock).to receive(:command_exec).and_return("hoge")
      allow(server).to receive(:backend).and_return(backend_mock)
      expect(server.command_exec("echo hoge")).to eq "hoge"
    end
  end
end
