require 'spec_helper'

describe "Ajimi::Server" do
  before do
    @server = Ajimi::Server.new(
      host: "server.example.com",
      user: "minamijoyo",
      key: "~/.ssh/id_rsa"
    )
  end

  describe "#data" do
    it "returns passed value" do
      expect(@server.data("hoge")).to eq("hoge")
    end
  end
end
