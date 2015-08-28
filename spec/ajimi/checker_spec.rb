require 'spec_helper'

describe Ajimi::Checker do
  before do
    @source = Ajimi::Server.new(
        host: "sandbox-app03b",
        user: "morita",
        key: "~/.ssh/id_rsa"
    )
    @target = Ajimi::Server.new(
        host: "sandbox-webapp",
        user: "ec2-user",
        key: "~/.ssh/MasayukiMORITA.pem"
    )
    @root = "/root"
    @checker = Ajimi::Checker.new(@source, @target, @root)
  end

  describe "#check" do
    context "when 2 servers have same data" do
      it "returns true" do
        result = @checker.check
        expect(result).to be true
      end
    end

  end
end
