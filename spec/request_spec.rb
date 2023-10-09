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

# Request Specs
module RestClientWrapper # rubocop:disable Metrics/ModuleLength

  describe Request do
    before(:context) do
      @api_uri = URI.parse("http://fake_site.com")
      @param_hash = { key: "value" }
      @non_hash_value = 1
    end

    describe "#http_method" do

      before(:example) do
        @non_http_method = :test
        @non_symbol_value = 1
      end

      context "when http_method is not a valid http method" do

        it "will raise TypeError" do
          expect { Request.new(http_method: @non_http_method, uri: @api_uri) }.to raise_error(ArgumentError)
        end

      end

      context "when http_method is not a symbol" do

        it "will raise TypeError" do
          expect { Request.new(http_method: @non_symbol_value, uri: @api_uri) }.to raise_error(TypeError)
        end

      end

      context "when http method :get is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :get, uri: @api_uri)
          expect(request.http_method).to eq(:get)
        end

      end

      context "when http method :post is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :post, uri: @api_uri)
          expect(request.http_method).to eq(:post)
        end

      end

      context "when http method :put is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :put, uri: @api_uri)
          expect(request.http_method).to eq(:put)
        end

      end

      context "when http method :delete is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :delete, uri: @api_uri)
          expect(request.http_method).to eq(:delete)
        end

      end

      context "when http method :connect is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :connect, uri: @api_uri)
          expect(request.http_method).to eq(:connect)
        end

      end

      context "when http method :options is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :options, uri: @api_uri)
          expect(request.http_method).to eq(:options)
        end

      end

      context "when http method :trace is assigned" do

        it "value is assigned to request http_method" do
          request = Request.new(http_method: :trace, uri: @api_uri)
          expect(request.http_method).to eq(:trace)
        end

      end

    end

    describe "#segment_params" do

      context "when segment_params is not a hash" do

        it "will raise TypeError" do
          expect { Request.new(http_method: :get, uri: @api_uri, segment_params: @non_hash_value) }.to raise_error(TypeError)
        end

      end

      context "when segment_params is a hash" do

        it "value is assigned to request segment_params" do
          request = Request.new(http_method: :get, uri: @api_uri, segment_params: @param_hash)
          expect(request.segment_params).to eq(@param_hash)
        end

      end

    end

    describe "#payload" do

      context "when payload is not a hash" do

        it "will raise TypeError" do
          expect { Request.new(http_method: :put, uri: @api_uri, segment_params: @param_hash, payload: @non_hash_value) }.to raise_error(TypeError)
        end

      end

      context "when payload is a hash" do

        it "value is assigned to request payload" do
          request = Request.new(http_method: :get, uri: @api_uri, segment_params: @param_hash, payload: @param_hash)
          expect(request.payload).to eq(@param_hash)
        end

      end

    end

    describe "#headers" do

      context "when headers is not a hash" do

        it "will raise TypeError" do
          request = Request.new(http_method: :get, uri: @api_uri, segment_params: @param_hash, payload: @param_hash)
          expect { request.headers = @non_hash_value }.to raise_error(TypeError)
        end

      end

      context "when headers is a hash" do

        it "value is assigned to request header" do
          request = Request.new(http_method: :get, uri: @api_uri, segment_params: @param_hash, payload: @param_hash)
          expect(request.payload).to eq(@param_hash)
        end

      end

    end

  end

end
