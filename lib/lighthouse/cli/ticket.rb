module Lighthouse
  module CLI
    class Ticket

      def self.show(ticket)
        pp "Title: #{ticket.title}"
        pp "State: #{ticket.state}"
        pp ticket.body
      end

      def self.update(ticket, options)
        ticket.state = options[:state]
        ticket.save
      end
    end
  end
end