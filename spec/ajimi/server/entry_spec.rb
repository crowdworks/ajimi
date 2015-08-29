require 'spec_helper'

describe "Ajimi::Server::Entry" do

  describe "#==" do
    let(:source) { Ajimi::Server::Entry.new(
      path: "path", mode: "mode", user: "user", group: "group", bytes: "bytes"
    ) }

    context "when same params" do
      let(:same) { Ajimi::Server::Entry.new(
        path: "path", mode: "mode", user: "user", group: "group", bytes: "bytes"
      ) }
      it "is considered same as other" do
        expect(source).to eq same
      end
    end
    
    context "when different params" do
      let(:path_changed) { Ajimi::Server::Entry.new(
        path: "path_changed", mode: "mode", user: "user", group: "group", bytes: "bytes"
      ) }
      let(:mode_changed) { Ajimi::Server::Entry.new(
        path: "path", mode: "mode_changed", user: "user", group: "group", bytes: "bytes"
      ) }
      let(:user_changed) { Ajimi::Server::Entry.new(
        path: "path", mode: "mode", user: "user_changed", group: "group", bytes: "bytes"
      ) }
      let(:group_changed) { Ajimi::Server::Entry.new(
        path: "path", mode: "mode", user: "user", group: "group_changed", bytes: "bytes"
      ) }
      let(:bytes_changed) { Ajimi::Server::Entry.new(
        path: "path", mode: "mode", user: "user", group: "group", bytes: "bytes_changed"
      ) }

      it "differs path" do
        expect(source).not_to eq path_changed
      end

      it "differs mode" do
        expect(source).not_to eq mode_changed
      end

      it "differs user" do
        expect(source).not_to eq user_changed
      end

      it "differs group" do
        expect(source).not_to eq group_changed
      end

      it "differs bytes" do
        expect(source).not_to eq bytes_changed
      end

    end
  end

  describe "#to_s" do
    let(:line) { "/home/ec2-user, drwx------, ec2-user, ec2-group, 4096" }
    let(:entry) { Ajimi::Server::Entry.new(
      path: "/home/ec2-user",
      mode: "drwx------",
      user: "ec2-user",
      group: "ec2-group",
      bytes: "4096"
    ) }
    it "returns string joined with comma" do
      expect(entry.to_s). to eq line
    end
    
  end
  describe ".parse" do
    let(:line) { "/home/ec2-user, drwx------, ec2-user, ec2-group, 4096" }
    let(:entry) { Ajimi::Server::Entry.new(
      path: "/home/ec2-user",
      mode: "drwx------",
      user: "ec2-user",
      group: "ec2-group",
      bytes: "4096"
    ) }

    it "returns parsed entry instance" do
      parsed = make_entry(line)
      expect(parsed).to eq entry
    end
    
    it "returns original string" do
      expect(make_entry(line).to_s).to eq line
    end
  end
end
