module Lighthouse
  module CLI
    class Output

      def initialize(options)
        if options[:ticket]
          self.send(:ticket, options)
        elsif options[:project]
          self.send(:project, options)
        end
      end

      def ticket(options)
        ticket = Lighthouse::Ticket.find(options[:ticket], :params => { :project_id => 96940 })

        if options[:state]
          if Lighthouse::CLI::Ticket.update(ticket, options)
            puts "** Ticket Updated **"
            Lighthouse::CLI::Ticket.show(ticket)
          end
        else
          Lighthouse::CLI::Ticket.show(ticket)
        end

        if options[:open]
          `open #{ticket.url}`
        end
      end

      def project(options)
        projects = Lighthouse::Project.find(:all)

        if options[:list]
          Lighthouse::CLI::Project.list(projects)
        end

      end

    end
  end
end