require 'net/http'
require 'multi_json'

module Customerio
  class APIClient
    def initialize(app_key, options = {})
      options[:region] = Customerio::Regions::US if options[:region].nil? || options[:region].empty?
      options[:url] = Customerio::Regions.api_url_for(options[:region]) if options[:url].nil? || options[:url].empty?

      @client = Customerio::BaseClient.new({ app_key: app_key }, options)
    end

    def send_email(req)
      raise "request must be an instance of Customerio::SendEmailRequest" unless req.is_a?(Customerio::SendEmailRequest)
      response = @client.request(:post, send_email_path, req.message)

      case response
      when Net::HTTPSuccess then
        JSON.parse(response.body)
      when Net::HTTPBadRequest then
        json = JSON.parse(response.body)
        raise Customerio::InvalidResponse.new(response.code, json['meta']['error'], response)
      else
        raise InvalidResponse.new(response.code, response.body)
      end
    end

    private

    def send_email_path
      "/v1/send/email"
    end
  end
end
