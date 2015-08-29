require 'spec_helper'

describe "Ajimi::Client" do

  describe "#check" do
    let(:client) { Ajimi::Client.new }
    context "when no diff" do
      it "returns true" do
        checker = Ajimi::Checker.new(Ajimi::Server.new, Ajimi::Server.new, "/")
        allow(checker).to receive(:check).and_return(true)
        expect(client.check(checker)).to be true
      end
    end

    context "when some diff" do
      it "returns false" do
        checker = Ajimi::Checker.new(Ajimi::Server.new, Ajimi::Server.new, "/")
        allow(checker).to receive(:check).and_return(false)
        expect(client.check(checker)).to be false
      end
    end

  end

  describe "#run" do
    context "when no diff" do
      it "puts no diff" do
        client = Ajimi::Client.new
        allow(client).to receive(:check).and_return(true)
        expect{ client.run }.to output("no diff\n").to_stdout
      end
    end

    context "when some diff" do
      it "puts some diff" do
        client = Ajimi::Client.new
        allow(client).to receive(:check).and_return(false)
        expect{ client.run }.to output("some diff\n").to_stdout
      end
    end

  end

end
