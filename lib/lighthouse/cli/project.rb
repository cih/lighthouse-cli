module Lighthouse
  module CLI
    class Project

      def self.list(projects)
        all.each do |project|
          pp "ID: #{project.id}, Name: #{project.name}"
        end
      end

    end
  end
end