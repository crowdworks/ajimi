require 'spec_helper'

describe "Ajimi::Server" do
  describe "#host" do
    context "when server has name and no ssh_options" do
      let(:server) { Ajimi::Server.new("name") }
      it "returns name" do
        expect(server.host).to eq "name"
      end
    end

    context "when server has name and ssh_options(with host parameter)" do
      let(:server) { Ajimi::Server.new("name", { ssh_options: { host: "host" } }) }
      it "returns host" do
        expect(server.host).to eq "host"
      end
    end

    context "when server has name and ssh_options(with no host parameter)" do
      let(:server) { Ajimi::Server.new("name", { ssh_options: { user: "user" } }) }
      it "returns name" do
        expect(server.host).to eq "name"
      end
    end

  end

  let(:dummy_response) {
    "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705\n" +
    "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096\n"
  }
  let(:find_return) { [
    "/home/ec2-user, drwx------, ec2-user, ec2-user, 4096",
    "/home/ec2-user/.bash_history, -rw-------, ec2-user, ec2-user, 1705",
  ] }
  let(:server) { Ajimi::Server.new("dummy", {}) }

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

  describe "#build_find_cmd" do
    describe "with nice and ionice commands" do
      it "is wrapped in nice and ionice commands" do
        expect(server.send(:build_find_cmd, "/etc")).to match %r|nice \-n 19 ionice \-c 3 \-n 7 find|
      end
    end

    describe "with dir options" do
      it "includes dir -ls" do
        expect(server.send(:build_find_cmd, "/etc")).to match %r|/etc \-ls|
      end
    end

    describe "with find_max_depth option" do
      context "when find_max_depth is nil" do
        it "does not include -find_max_depth" do
          expect(server.send(:build_find_cmd, "/etc")).not_to match %r|\-maxdepth|
        end
      end

      context "when find_max_depth is not nil" do
        it "includes -find_max_depth" do
          expect(server.send(:build_find_cmd, "/etc", 4)).to match %r|\-maxdepth 4|
        end
      end
    end

    describe "with pruned_paths option" do
      context "when pruned_paths are empty" do
        it "does not include -prune" do
          expect(server.send(:build_find_cmd, "/etc")).not_to match %r|\-prune|
        end
      end

      context "when pruned_paths are not empty" do
        it "includes -prune" do
          expect(server.send(:build_find_cmd, "/etc", 4, ["/dev", "/proc"])).to match %r|\-prune|
        end
      end
    end
  end

  describe "#build_pruned_paths_option" do
    context "when pruned_paths are empty array" do
      it "returns empty string" do
        expect(server.send(:build_pruned_paths_option)).to eq ""
      end
    end

    context "when pruned_paths are not empty array" do
      it "returns a 1 prune path" do
        expect(server.send(:build_pruned_paths_option, ["/dev"])).to eq " -path /dev -prune"
      end

      it "returns 2 prune paths joined with -o" do
        expect(server.send(:build_pruned_paths_option, ["/dev", "/proc"])).to eq " -path /dev -prune -o -path /proc -prune"
      end
    end
  end

end
