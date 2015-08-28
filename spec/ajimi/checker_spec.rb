require 'spec_helper'

describe Ajimi::Checker do
  before do
    @server1 = Ajimi::Server.new(
      host: "server1.example.com",
      user: "minamijoyo",
      key: "~/.ssh/id_rsa"
    )
    @server2 = Ajimi::Server.new(
      host: "server2.example.com",
      user: "minamijoyo",
      key: "~/.ssh/id_rsa"
    )
    @checker = Ajimi::Checker.new(@server1, @server2)
  end

  describe "#check" do
    context "when 2 servers have same data" do
      it "returns true" do
        @server1.data("hoge")
        @server2.data("hoge")
        result = @checker.check
        expect(result).to be true
      end
    end

    context "when 2 servers have different data" do
      it "returns false" do
        @server1.data("hoge")
        @server2.data("fuga")
        result = @checker.check
        expect(result).to be false
      end
    end

  end
end
