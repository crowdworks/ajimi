require 'spec_helper'

describe "Ajimi#Config" do

  describe ".load" do
    let(:ajimi_file_content) { <<-"AJIMIFILE"
source_host "source_host_value"
source_user "source_user_value"
source_key "source_key_value"
target_host "target_host_value"
target_user "target_user_value"
target_key "target_key_value"
check_root_path "check_root_path_value"
ignore_paths [
  "/path_to_ignore1",
  "/path_to_ignore2"
]
ignore_contents ({
  "/path_to_content" => /ignore_pattern/
})
    AJIMIFILE
    }

    let(:loaded_config) { {
      source_host: "source_host_value",
      source_user: "source_user_value",
      source_key: "source_key_value",
      target_host: "target_host_value",
      target_user: "target_user_value",
      target_key: "target_key_value",
      check_root_path: "check_root_path_value",
      ignore_paths: ["/path_to_ignore1", "/path_to_ignore2"],
      ignore_contents: { "/path_to_content" => /ignore_pattern/ }
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
