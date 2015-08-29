require 'spec_helper'

describe "Ajimi::Client" do
  let(:client) { Ajimi::Client.new }
  let(:checker) { Ajimi::Checker.new(Ajimi::Server.new, Ajimi::Server.new, "/") }
  describe "#check" do
    context "when checker returns true" do
      it "returns true" do
        allow(checker).to receive(:check).and_return(true)
        expect(client.check(checker)).to be true
      end
    end

    context "when checker returns false" do
      it "returns false" do
        allow(checker).to receive(:check).and_return(false)
        expect(client.check(checker)).to be false
      end
    end

  end

  describe "#run" do
    context "when target is the same as source" do
      it "puts no diff" do
        allow(client).to receive(:check).and_return(true)
        expect{ client.run }.to output("no diff\n").to_stdout
      end
    end

    context "when target differs from source" do
      it "puts some diff" do
        allow(client).to receive(:check).and_return(false)
        expect{ client.run }.to output("some diff\n").to_stdout
      end
    end

  end

end
