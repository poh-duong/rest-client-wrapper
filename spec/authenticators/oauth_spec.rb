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

require "spec_helper"

# Authenticator::Oauth Specs
module RestClientWrapper

  describe Authenticator::Oauth do

    before(:context) do
      @client_id = "client_id"
      @client_secret = "client_secret"
      @api_token_uri = URI.parse("http://fake_oauth_token.com/token_url_path")
    end

    describe "::get_access_token" do

      before(:example) do
        WebMock.reset_executed_requests!
        @oauth = Authenticator::Oauth.new(
          site:           "#{ @api_token_uri.scheme }://#{ @api_token_uri.host }",
          token_url_path: @api_token_uri.path,
          client_id:      @client_id,
          client_secret:  @client_secret
        )
        @current_token = FactoryBot.build(:token).token
        request = FactoryBot.build(:oauth_token_request, { headers: FactoryBot.build(:request_headers, { host: @api_token_uri.host }).to_h }).to_h
        response = FactoryBot.build(:auth_token_response).to_h
        @response_body = response[:body]
        response[:body] = lambda { |_request|
          sleep 1 # Simulate network latency.
          @response_body
        }
        @authenticate_request = stub_request(:post, @api_token_uri.to_s).with(request).to_return(response)
      end

      context "when multiple threads are trying to authenticate" do

        it "will only make one API request to renew the access token" do
          t1 = Thread.new do
            Authenticator::Oauth.authenticate(client_id: @client_id)
          end

          sleep(1) # Give t1 a head start so that it can get the lock before t2 does
          t2 = Thread.new do
            Authenticator::Oauth.authenticate(client_id: @client_id, access_token: @current_token)
          end

          t1.join
          t2.join

          parsed_response = JSON.parse(@response_body).symbolize_keys

          expect(@oauth.tokens[@client_id][:access_token]).to eq(parsed_response[:access_token])
          # Only expect one request as thread 1 (t1) has already got a new token thread 2 (t2) will use the new token.
          expect(@authenticate_request).to have_been_requested.times(1)
        end

      end

      context "when token is expired" do

        before(:example) do
          WebMock.reset_executed_requests!
          @expired_token = FactoryBot.build(:token).token
          @request = FactoryBot.build(:oauth_token_request, { headers: FactoryBot.build(:request_headers, { host: @api_token_uri.host }).to_h }).to_h
          @response = FactoryBot.build(:auth_token_response).to_h
          @authenticate_request = stub_request(:post, @api_token_uri.to_s).with(@request).to_return(@response)
        end

        it "will make an API call to get a new token" do
          Authenticator::Oauth.authenticate(client_id: @client_id, access_token: @expired_token)
          parsed_response = JSON.parse(@response[:body]).symbolize_keys

          expect(@oauth.tokens[@client_id][:access_token]).to eq(parsed_response[:access_token])
          expect(@authenticate_request).to have_been_requested.times(1)
        end

      end

    end

  end

end
