# Copyright (C) 2019 The University of Adelaide
#
# This file is part of Rest-Client-Wrapper.
#
# Rest-Client-Wrapper is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rest-Client-Wrapper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rest-Client-Wrapper. If not, see <http://www.gnu.org/licenses/>.
#

require "json"
require "rest_client"
require_relative "auth"
require_relative "../constants"
require_relative "../http"

module RestClientWrapper

  # Authenticator
  module Authenticator

    # Oauth
    class Oauth

      include Auth

      attr_reader :client_id

      @@api_client = {} # rubocop:disable Style/ClassVars

      def initialize(client_id:, **config)
        @client_id = client_id
        @@api_client[client_id] = { lock: Mutex.new, settings: config, access_token: nil, refresh_token: nil }
      end

      def tokens
        return @@api_client
      end

      def access_token
        return @@api_client&.[](@client_id)&.[](:access_token)
      end

      def generate_auth
        Authenticator::Oauth.authenticate(client_id: @client_id) if @@api_client&.[](@client_id)&.[](:access_token).nil?
        access_token = @@api_client&.[](@client_id)&.[](:access_token)
        raise StandardError "Unable to authenticate #{ @client_id }" if @@api_client&.[](@client_id)&.[](:access_token).nil?

        return { Authorization: "Bearer #{ access_token }" }
      end

      def self.authenticate(client_id:, access_token: nil) # rubocop:disable Metrics/CyclomaticComplexity,  Metrics/PerceivedComplexity
        # Ensure that other threads aren't checking and updating the token at the same time
        @@api_client[client_id][:lock].synchronize do
          # Return access_token from @@api_client when the current_token is different to what's in @@api_client as it's already been refreshed
          return @@api_client[client_id][:access_token] if !access_token.nil? && !@@api_client[client_id][:access_token].nil? && @@api_client[client_id][:access_token].casecmp(access_token).nonzero?

          payload = {
            grant_type:    GrantType::CLIENT_CREDENTIALS,
            client_id:,
            client_secret: @@api_client&.[](client_id)&.[](:settings)&.[](:client_secret)
          }
          url = "#{ @@api_client&.[](client_id)&.[](:settings)&.[](:site) }#{ @@api_client&.[](client_id)&.[](:settings)&.[](:token_url_path) }"

          response = ::RestClient::Request.execute(method: :post, url:, payload:)

          if Http.ok?(response.code)
            content_type = MIME::Types[response&.headers&.[](:content_type)].first
            raise StandardError "Unable to retreive token, response was in a unexpected format" unless content_type == "application/json"

            token_payload = JSON.parse(response.body)
            @@api_client[client_id][:access_token] = token_payload["access_token"]
            @@api_client[client_id][:refresh_token] = token_payload["refresh_token"]
          end
        end
      end

    end

  end

end
