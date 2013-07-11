module Lighthouse
  module CLI

    class << self
      attr_accessor :token, :account, :project_id
    end

    CLI_CONFIG = YAML.load_file("#{File.expand_path('../../../../config/config.yml', __FILE__)}")

    Lighthouse::CLI.account = CLI_CONFIG["account"]
    Lighthouse::CLI.project_id = CLI_CONFIG["project_id"]
    Lighthouse::CLI.token = CLI_CONFIG["token"]

    class Config

      def self.set_token(token)
        settings = CLI_CONFIG
        settings["token"] = token
        save(settings)
      end

      def self.set_current_project(project)
        settings = CLI_CONFIG
        settings["current_project"] = project
        save(settings)
      end

      def self.save(settings)
        File.open("#{File.expand_path('../../../../config/config.yml', __FILE__)}", "w+") {|f| f.write(settings.to_yaml) }
      end

    end
  end
end