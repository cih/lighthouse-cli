module Lighthouse
  module CLI
    class Request

      require 'json'

      BASE = "http://#{Lighthouse::CLI.account}.lighthouseapp.com"

      def self.perform(method, endpoint, options={})
        HTTParty.send(method.to_sym, "#{BASE}/#{endpoint}",
                      :query => {:_token => Lighthouse::CLI.token},
                      :headers => {"Content-Type" => "application/json"},
                      :body => {:ticket => options}.to_json)
      end
    end
  end
end