require 'spec_helper'

describe Ajimi do
  before do
    @ajimi = Ajimi::Controller.new
  end

  describe "#check" do
    context "when no diff" do
      it "returns true" do
        expect(@ajimi.check).to be true
      end
    end
  end

  describe "#run" do
    context "when no diff" do
      it "puts no diff" do
        expect{ @ajimi.run }.to output("no diff\n").to_stdout
      end
    end
  end

end
