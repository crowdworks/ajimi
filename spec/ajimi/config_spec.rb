require 'spec_helper'

describe "Ajimi#Config" do

  describe ".load" do
    let(:ajimi_file_content) { <<-"AJIMIFILE"
source "source_host_value", {
  ssh_options: {
    host: "overriden_source_host_value",
    user: "source_user_value",
    key: "source_key_value"
  }
}
target "target_host_value", {
  ssh_options: {
    user: "target_user_value",
    key: "target_key_value"
  }
}
check_root_path "check_root_path_value"
ignored_paths [
  "/path_to_ignored1",
  "/path_to_ignored2"
]
ignored_contents ({
  "/path_to_content" => /ignored_pattern/
})
pending_paths [
  "/path_to_pending1",
  "/path_to_pending2"
]
pending_contents ({
  "/path_to_content" => /pending_pattern/
})
    AJIMIFILE
    }

    let(:loaded_config) { {
      source: {
        name: "source_host_value",
        ssh_options: {
          host: "overriden_source_host_value",
          user: "source_user_value",
          key: "source_key_value"
        }
      },
      target: {
        name: "target_host_value",
        ssh_options: {
          user: "target_user_value",
          key: "target_key_value"
        }
      },
      check_root_path: "check_root_path_value",
      ignored_paths: ["/path_to_ignored1", "/path_to_ignored2"],
      ignored_contents: { "/path_to_content" => /ignored_pattern/ },
      pending_paths: ["/path_to_pending1", "/path_to_pending2"],
      pending_contents: { "/path_to_content" => /pending_pattern/ }
    } }

    before do
      expect(::File).to receive(:read).and_return(ajimi_file_content)
      @config = Ajimi::Config.load("./Ajimifile")
    end

    it "returns config hash" do
      expect(@config).to eq loaded_config
    end
    
  end
end
