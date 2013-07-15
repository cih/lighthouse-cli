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

        opts.on("-n String") do |n|
          @@options[:nickname] = n
        end

        opts.on("-u String") do |u|
          @@options[:user_id] = u
        end

        opts.on("-a String") do |a|
          @@options[:assigned_user_id] = a
        end
      end.parse!

      if @@options[:api_key]
        Lighthouse::CLI::Config.save_setting(:api_key, options.delete(:api_key))
      end

      if @@options[:current_project]
        Lighthouse::CLI::Config.save_setting(:current_project, options.delete(:current_project))
      end

      if @@options[:open]
        `open `
      end

      AVAILABLE_COMMANDS = self.instance_methods(false)

      def start
        @method = ARGV[0]
        @ticket_id = ARGV[1]
        @project_id = Lighthouse::CLI.project_id

        if @method
          if self.respond_to?(@method.to_sym)
            self.send(@method.to_sym)
          else
            puts "** ERROR #{@method} is not a valid command, type `lighthouse help` for a full list of commands **"
          end
        else
          puts "** ERROR Please givae a valid command, type `lighthouse help` for a full list of commands **"
        end
      end

      def help
        puts "Welcome to Lighthouse CLI version #{Lighthouse::CLI::VERSION} \n".green
        puts "DESCRIPTION\n".yellow
        puts <<-EOF
        Show, list and update tickets without leaving the command line.\n
            EOF

            puts "USAGE\n".yellow

            puts <<-EOF
        lighthouse [action] [options]


        CONFIG - This stores your settings in a config.yml file

            lighthouse config [options]

              -t <api_token> # Set your lighthouse api token

              -p <project_id> # Set the current project

              -a <account_name> # Set the account name

        TICKETS - Show, list and update tickets

            lighthouse show <ticket_number> # Returns the ticket

            lighthouse update <ticket_number> [options]

              -s <new_state> # Update the state of the ticket

              -a <assigned_user> # Update the assigned user (by ID or nickname)

        PROJECTS - List projects

            lighthouse projects # List projects

            lighthouse project <project_number> # Shows current project

        USERS - Show users assigned to the current project

            lighthouse users # Shows all users

            lighthouse users -u 12345 -n cholmes # Assign nickname 'cholmes' to user #12345
            EOF
      end

      def config
        CLI_CONFIG.each_pair {|k, v| puts "#{k} : #{v}"}
      end

      # GET /projects/#{project_id}/tickets/#{number}.xml
      #
      def show
        endpoint = "/projects/#{@project_id}/tickets/#{@ticket_id}.xml"

        response = Lighthouse::CLI::Request.perform(:get, endpoint)

        if response.code == 200
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
        else
          puts "** ERROR - Is #{@ticket_id} a valid ticket number? **"
        end
      end

      # PUT /projects/#{project_id}/tickets/#{number}.xml
      #
      def update
        endpoint = "/projects/#{@project_id}/tickets/#{@ticket_id}.xml"

        @@options[:assigned_user_id] = find_user(@@options[:assigned_user_id]) if @@options[:assigned_user_id]

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


      # GET /users.xml
      #
      def users
        # Grab the user list from the API if not already cached
        if Lighthouse::CLI.project_users.nil?
          endpoint = "/projects/#{@project_id}/memberships.xml"
          response = Lighthouse::CLI::Request.perform(:get, endpoint)
          doc = REXML::Document.new(response.body)

          users = {}
          doc.elements.each('memberships/membership/user') do |user|
            users[user.elements["id"].text.to_sym] = {
              :name => user.elements["name"].text.strip,
              :nickname => nil
            }
          end

          Lighthouse::CLI.project_users = users
          Lighthouse::CLI::Config.save_setting(:project_users, users)
        end

        users = Lighthouse::CLI.project_users

        if @@options[:user_id] && @@options[:nickname]
          users[@@options[:user_id].to_sym][:nickname] = @@options[:nickname]
          Lighthouse::CLI.project_users = users
          Lighthouse::CLI::Config.save_setting(:project_users, users)
        end

        users = Lighthouse::CLI.project_users
        puts "ID\tName\tNickname"
        users.each_pair do |user_id, details|
          puts "#{user_id}\t#{details[:name]}\t#{details[:nickname]}"
        end
      end


      def find_user(query)
        # Finds a user from the config either by ID or nickname
        users = Lighthouse::CLI.project_users

        if query.to_i > 0
          return query.to_i if users.has_key?(query.to_sym)
        else
          users.each_pair do |id, user|
            return id.to_s.to_i if user[:nickname] == query
          end
        end

        nil
      end

    end
  end
end