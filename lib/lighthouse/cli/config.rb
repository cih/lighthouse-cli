module Lighthouse
  module CLI
    class Config

      def self.set_api_key(api_key)
        settings = CLI_CONFIG
        settings["api_key"] = api_key
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