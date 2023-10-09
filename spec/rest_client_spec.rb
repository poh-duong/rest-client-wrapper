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

# RestClientWrapper
module RestClientWrapper # rubocop:disable Metrics/ModuleLength

  describe RestClient do

    before(:context) do
      @api_url = URI.parse("http://fake_api_site.com")
      @rest_client = RestClient.new(host: @api_url.to_s)

      @client_id = "client_id"
      @client_secret = "client_secret"
      @api_token_uri = URI.parse("http://fake_oauth_token.com/token_url_path")

      @oauth_client = RestClient.new(host: @api_url.to_s)
      @oauth_client.authenticator = Authenticator::Oauth.new(
        site:           "#{ @api_token_uri.scheme }://#{ @api_token_uri.host }",
        token_url_path: @api_token_uri.path,
        client_id:      @client_id,
        client_secret:  @client_secret
      )
    end

    describe "#execute" do

      before(:example) do
        @course_id = "fake_course_id"
        @uri = "/api/v1/courses/#{ @course_id }"
        @rest_client.authenticator = Authenticator::Basic.new(username: "username", password: "password")
        request = FactoryBot.build(:request, { body: {}, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
        response = FactoryBot.build(:response).to_h
        @api_request = stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)
      end

      context "when the request is valid" do

        it "will return a valid response" do
          request = Request.new(http_method: :get, uri: "/api/v1/courses/%<course_id>s")
          request.segment_params = { course_id: @course_id }
          @rest_client.execute(request:)
          expect(@api_request).to have_been_requested
          expect(@api_request).to have_been_requested.times(1)
        end

      end

      context "when put request with query params and payload" do

        before(:example) do
          @request = Request.new(http_method: :put, uri: "/api/v1/courses/%<course_id>s")
          @request.segment_params = { course_id: @course_id }
          @request.payload = { id: "value" }
          @request.query_params = { param: "value" }

          @mock_request = FactoryBot.build(:request, { body: @request.payload, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
          @response = FactoryBot.build(:response).to_h
        end

        it "has query string params in URL and payload as json in body" do
          @api_request = stub_request(:put, "#{ @api_url }#{ @uri }?#{ @request.query_params.to_query }").with(@mock_request).to_return(@response)
          @rest_client.execute(request: @request)
          expect(@api_request).to have_been_requested
        end

      end

      context "when access token is no longer valid/expired" do

        before(:example) do
          @uri = "/api/v1/courses/course_id"
          @requests = []
          request = FactoryBot.build(:request, { body: {}, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
          # Respond with unauthorized error to force reauth
          response = FactoryBot.build(:response, { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized] }).to_h

          @requests << stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)

          oauth_request = FactoryBot.build(:oauth_token_request, { headers: FactoryBot.build(:request_headers, { host: @api_token_uri.host }).to_h }).to_h
          oauth_response = FactoryBot.build(:auth_token_response).to_h

          @requests << stub_request(:post, @api_token_uri.to_s).with(oauth_request).to_return(oauth_response)

          response = FactoryBot.build(:response, { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok] }).to_h
          @requests << stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)
        end

        it "will get a new access_token" do
          request = Request.new(http_method: :get, uri: @uri)
          request.segment_params = { course_id: @course_id }
          @oauth_client.execute(request:)
          @requests.each do |req|
            expect(req).to have_been_requested.times(1)
          end
        end

      end

      context "when there's a response with a status code not in the retry list" do

        before(:example) do
          WebMock.reset_executed_requests!
          request = FactoryBot.build(:request, { body: {}, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
          response = FactoryBot.build(:response, { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:internal_server_error] }).to_h
          @api_request = stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)
        end

        it "will raise an exception" do
          request = Request.new(http_method: :get, uri: "/api/v1/courses/%<course_id>s")
          request.segment_params = { course_id: @course_id }
          expect { @rest_client.execute(request:) }.to raise_exception(RestClientError)
          expect(@api_request).to have_been_requested.times(1)
        end

      end

      context "when there's a response status code is 429 (too many requests)" do

        before(:example) do
          WebMock.reset_executed_requests!
          request = FactoryBot.build(:request, { body: {}, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
          response = FactoryBot.build(:response, { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:too_many_requests] }).to_h
          @api_request = stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)
        end

        it "will retry three times than raise an exception" do
          request = Request.new(http_method: :get, uri: "/api/v1/courses/%<course_id>s")
          request.segment_params = { course_id: @course_id }
          expect { @rest_client.execute(request:) }.to raise_exception(RestClientError)
          expect(@api_request).to have_been_requested.times(4) # initial request + 3 retries
        end

      end

    end

    describe "#make_request" do

      before(:example) do
        WebMock.reset_executed_requests!
        @course_id = "fake_course_id"
        @uri = "/api/v1/courses/#{ @course_id }"
        @rest_client.authenticator = Authenticator::Basic.new(username: "username", password: "password")
        request = FactoryBot.build(:request, { body: {}, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
        response = FactoryBot.build(:response).to_h
        @api_request = stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)
      end

      context "when the request is valid" do

        it "will return a valid response" do
          @rest_client.make_request(http_method: :get, uri: @uri)
          expect(@api_request).to have_been_requested
          expect(@api_request).to have_been_requested.times(1)
        end

      end

    end

    describe "#get_all_pages" do

      before(:example) do
        WebMock.reset_executed_requests!
        @uri = "/api/v1/courses/enrollments"
        @per_page = 500
        @requests = []

        @rest_client.authenticator = Authenticator::Basic.new(username: "username", password: "password")

        # Stubing requests and responses for pagination calls
        1.upto(4) do |page_number|
          response = FactoryBot.build(:paginated_response).to_h
          # Add "next" link header for all responses except the last one. (i.e. so that we're only processing 4 pages)
          response[:headers][:link] = "<#{ @api_url }#{ @uri }?page=#{ page_number + 1 }&per_page=#{ @per_page }>; rel=\"next\"" if page_number < 4
          request = FactoryBot.build(:request, { body: { per_page: @per_page, page: page_number }, headers: FactoryBot.build(:request_headers, { host: @api_url.host }).to_h }).to_h
          api_request = stub_request(:get, "#{ @api_url }#{ @uri }").with(request).to_return(response)
          @requests << api_request
        end

      end

      context "when a pagination request is made" do

        it "will recursively make pagination requests until there's no page left" do
          skip "TODO: move to Paginator"
          @rest_client.get_all_pages(http_method: :get, uri: @uri, payload: { per_page: @per_page })
          @requests.each do |request|
            expect(request).to have_been_requested.times(1)
          end

        end

      end

    end

    describe "#_validate_request" do

      before(:example) do
        @request = Request.new(http_method: :get, uri: "/public/api/v1/users/%<user_id>s")
      end

      context "when URI is missing a segments parameter" do

        it "will raise ArgumentError" do
          expect { @rest_client.send(:_validate_request, @request) }.to raise_error(ArgumentError)
        end

      end

      context "when all segment parameters are present for URI" do

        before(:example) do
          @request = Request.new(http_method: :get, uri: "/public/api/v1/courses/%<course_id>s/user/%<user_id>s")
          @request.segment_params = { user_id: "user_id", course_id: "course_id" }
        end

        it "return not raise an error" do
          expect { @rest_client.send(:_validate_request, @request) }.not_to raise_error
        end

      end

    end

  end

end
