require 'spec_helper'

describe Ajimi::Checker do
  describe "#check" do
    let(:source) { Ajimi::Server.new }
    let(:target) { Ajimi::Server.new }
    let(:checker) { Ajimi::Checker.new(source, target, "/") }
    let(:entry1) { Ajimi::Server::Entry.parse("path1, mode1, user1, group1, bytes1") }
    let(:entry2) { Ajimi::Server::Entry.parse("path2, mode2, user2, group2, bytes2") }
    let(:entry2_changed) { Ajimi::Server::Entry.parse("path2, mode2, user2, group2, bytes2_changed") }

    context "when 2 servers have same entries" do
      it "returns true" do
        allow(source).to receive(:entries).and_return([entry1, entry2])
        allow(target).to receive(:entries).and_return([entry1, entry2])
        expect(checker.check).to be true
      end
    end

    context "when 2 servers have different entries" do
      it "returns false" do
        allow(source).to receive(:entries).and_return([entry1, entry2])
        allow(target).to receive(:entries).and_return([entry1, entry2_changed])
        expect(checker.check).to be false
      end
    end

  end
end
