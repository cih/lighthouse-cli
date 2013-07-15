module Lighthouse
  module CLI
    class Request

      require 'json'

      BASE = "http://#{Lighthouse::CLI.account}.lighthouseapp.com"

      def self.perform(method, endpoint, options={})
        url = "#{BASE}/#{endpoint}"

        if method.to_sym == :get
          array = []
          options.each_pair do |k, v|
            array << "#{k}:#{v}"
          end
          options.merge!(:q => array.join(" "))

          HTTParty.send(method.to_sym, url,
                        :query => options.merge!({:_token => Lighthouse::CLI.token}),
                        :headers => {"Content-Type" => "application/json"})
        else
          HTTParty.send(method.to_sym, url,
                        :query => {:_token => Lighthouse::CLI.token},
                        :headers => {"Content-Type" => "application/json"},
                        :body => {:ticket => options}.to_json)
        end
      end
    end
  end
end