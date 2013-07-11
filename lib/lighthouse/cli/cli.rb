module Lighthouse
  module CLI
    require "rexml/document"
    class << self

      @@options = {}

      OptionParser.new do |opts|
        opts.on("-t String") do |api_key|
          @@options[:api_key] = api_key
        end

        opts.on("-p String") do |current_project|
          @@options[:current_project] = current_project
        end

        opts.on("-o") do |o|
          @@options[:open] = o
        end

        opts.on("-s String") do |s|
          @@options[:state] = s
        end

        opts.on("-c String") do |s|
          @@options[:body] = s
        end
      end.parse!

      if @@options[:api_key]
        Lighthouse::CLI::Config.set_api_key(options.delete(:api_key))
      end

      if @@options[:current_project]
        Lighthouse::CLI::Config.set_current_project(options.delete(:current_project))
      end

      if @@options[:open]
        `open `
      end

      def start
        @method = ARGV[0]
        @ticket_id = ARGV[1]
        @project_id = Lighthouse::CLI.project_id

        self.send(@method.to_sym)
      end

      # GET /projects/#{project_id}/tickets/#{number}.xml
      #
      def show
        endpoint = "/projects/#{@project_id}/tickets/#{@ticket_id}.xml"

        response = Lighthouse::CLI::Request.perform(:get, endpoint)

        doc = REXML::Document.new(response.body)
        doc.elements.each('ticket') do |p|
          puts "Title    : #{p.elements["title"].text}"
          puts "State    : #{p.elements["state"].text}"
          puts "Updated  : #{p.elements["updated-at"].text}"
          puts "Url      : #{p.elements["url"].text}"
          puts "Body     : #{p.elements["latest-body"].text}"
        end

        doc.elements.each('ticket/versions/version') do |v|
          next if v.elements["body"].attributes["nil"] # NEED TO SKIP 1ST
          puts "Comment  : #{v.elements["body"].text}"
        end
      end

      # PUT /projects/#{project_id}/tickets/#{number}.xml
      #
      def update
        endpoint = "/projects/#{@project_id}/tickets/#{@ticket_id}.xml"

        response = Lighthouse::CLI::Request.perform(:put, endpoint, @@options)

        if response.code == 200
          p "** SUCCESS - Ticket #{@ticket_id} has been updated. **"
          self.show
        else
          p "** ERROR - Ticket #{@ticket_id} has not been updated. **"
        end
      end

      # POST /projects/#{project_id}/tickets.xml
      #
      def create
        endpoint = "/projects/#{@project_id}/tickets/new.xml"

        response = Lighthouse::CLI::Request.put(endpoint, @options)

        puts output = REXML::Document.new(response.body)
      end

      # GET /projects.xml
      #
      def projects
        endpoint = "/projects.xml"

        response = Lighthouse::CLI::Request.perform(:get, endpoint)

        doc = REXML::Document.new(response.body)
        doc.elements.each('projects/project') do |p|
          puts "#{p.elements["id"].text} #{p.elements["name"].text}, #{p.elements["open-tickets-count"].text} open tickets."
        end
      end

      # GET /projects/#{project_id}.xml
      #
      def project
        endpoint = "/projects/#{@project_id}.xml"

        response = Lighthouse::CLI::Request.perform(:get, endpoint)

        doc = REXML::Document.new(response.body)
        doc.elements.each('project') do |p|
          puts "#{p.elements["id"].text} #{p.elements["name"].text}, #{p.elements["open-tickets-count"].text} open tickets."
        end
      end

    end
  end
end