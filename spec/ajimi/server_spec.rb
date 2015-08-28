require 'spec_helper'

describe "Ajimi::Server" do

  describe "#find" do
    let(:dummy_response) {
      "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096\n" +
      "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705\n"
    }

    let(:ret) { [
      "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096",
      "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705"
    ] }
    
    it "returns Array of line" do
      backend_mock = double('dummy backend')
      expect(backend_mock).to receive(:command_exec).and_return(dummy_response)
      server = Ajimi::Server.new
      allow(server).to receive(:backend).and_return(backend_mock)
      expect(server.find("/home/ec2-user")).to eq ret
    end
  end
  
  describe "#file" do
    let(:find_return) { [
      "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096",
      "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705",      
    ] }
    
    it "return parsed files" do
      server = Ajimi::Server.new
      allow(server).to receive(:find).and_return(find_return)
      files = server.files("/home/ec2-user")
      expect(files[0].path).to eq "/home/ec2-user"
      expect(files[1].path).to eq "/home/ec2-user/.bash_history"

    end
  end
  
  describe "#command_exec" do
    it "returns command stdout" do
      backend_mock = double('dummy backend')
      expect(backend_mock).to receive(:command_exec).and_return("hoge")
      server = Ajimi::Server.new
      allow(server).to receive(:backend).and_return(backend_mock)
      expect(server.command_exec("echo hoge")).to eq "hoge"
    end
  end
end
