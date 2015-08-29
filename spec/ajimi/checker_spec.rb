require 'spec_helper'

describe Ajimi::Checker do
  describe "#check" do
    context "when 2 servers have same data" do
      source = Ajimi::Server.new
      target = Ajimi::Server.new
      checker = Ajimi::Checker.new(source, target, "/")

      it "returns true" do
        allow(source).to receive(:files).and_return([
          Ajimi::Server::File.parse("path1, mode1, user1, group1, bytes1"),
          Ajimi::Server::File.parse("path2, mode2, user2, group2, bytes2")
        ])
        allow(target).to receive(:files).and_return([
          Ajimi::Server::File.parse("path1, mode1, user1, group1, bytes1"),
          Ajimi::Server::File.parse("path2, mode2, user2, group2, bytes2")
        ])
        result = checker.check
        expect(result).to be true
      end
    end

    context "when 2 servers have different data" do
      source = Ajimi::Server.new
      target = Ajimi::Server.new
      checker = Ajimi::Checker.new(source, target, "/")

      it "returns false" do
        allow(source).to receive(:files).and_return([
          Ajimi::Server::File.parse("path1, mode1, user1, group1, bytes1"),
          Ajimi::Server::File.parse("path2, mode2, user2, group2, bytes2")
        ])
        allow(target).to receive(:files).and_return([
          Ajimi::Server::File.parse("path1, mode1, user1, group1, hoge"),
          Ajimi::Server::File.parse("path2, mode2, user2, group2, bytes2")
        ])
        result = checker.check
        expect(result).to be false
      end
    end

  end
end
