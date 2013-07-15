module Lighthouse
  module CLI

    class << self
      attr_accessor :token, :account, :project_id, :project_users
    end

    CLI_CONFIG = YAML.load_file("#{File.expand_path('../../../../config/config.yml', __FILE__)}")

    Lighthouse::CLI.account = CLI_CONFIG["account"]
    Lighthouse::CLI.project_id = CLI_CONFIG["project_id"]
    Lighthouse::CLI.token = CLI_CONFIG["token"]
    Lighthouse::CLI.project_users = CLI_CONFIG["project_users"] || nil

    class Config

      def self.save_setting(key, value)
        settings = CLI_CONFIG
        settings[key.to_s] = value
        save(settings)
      end

      def self.save(settings)
        File.open("#{File.expand_path('../../../../config/config.yml', __FILE__)}", "w+") {|f| f.write(settings.to_yaml) }
      end

    end
  end
end