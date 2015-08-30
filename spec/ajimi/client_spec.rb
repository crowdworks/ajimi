require 'spec_helper'

describe "Ajimi::Client" do
  let(:client) { Ajimi::Client.new }
  let(:checker) { Ajimi::Checker.new(Ajimi::Server.new, Ajimi::Server.new, "/") }
  let(:reporter) { Ajimi::Reporter.new(checker) }

  before { client.checker = checker }

  describe "#check" do
    context "when checker returns true" do
      it "returns true" do
        allow(checker).to receive(:check).and_return(true)
        expect(client.check).to be true
      end
    end

    context "when checker returns false" do
      it "returns false" do
        allow(checker).to receive(:check).and_return(false)
        expect(client.check).to be false
      end
    end

  end

  describe "#report" do
    before { client.reporter = reporter }
    it "calls reporter.report" do
      expect(reporter).to receive(:report).and_return(true)
      expect(client.report(STDOUT)).to be true
    end
  end

  describe "#run" do
    context "when check returns true" do
      before { checker.result = true }
      it "return true" do
        allow(client).to receive(:check).and_return(true)
        allow(client).to receive(:report)
        expect(client.run).to be true
      end
    end

    context "when check return false" do
      before { checker.result = false }
      it "returns false" do
        allow(client).to receive(:check).and_return(false)
        allow(client).to receive(:report)
        expect(client.run).to be false
      end
    end

  end

end
