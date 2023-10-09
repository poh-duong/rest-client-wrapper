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

require "active_support"
require "active_support/core_ext"
require "json"
require "rack"
require "rest_client"
require_relative "exceptions"
require_relative "http"

module RestClientWrapper

  # RestClient
  class RestClient

    include Http

    attr_accessor :authenticator, :paginator

    DEFAULT_RETRY  = { max_retry: 0, wait: 0 }.freeze
    DEFAULT_CONFIG = {
      retries: {
        401 => { max_retry: 1, wait: 0 }, # unauthorized
        429 => { max_retry: 3, wait: 3 }  # too many requests
      }
    }.freeze

    def initialize(host:, **config)
      @host          = host
      @config        = config
      @retry_configs = {}.reverse_merge(DEFAULT_CONFIG[:retries])

      @config[:retries]&.each do |k, v|
        next unless Rack::Utils::HTTP_STATUS_CODES[k.to_i] # skip invalid codes

        @retry_configs[k.to_i] = v.reverse_merge(DEFAULT_RETRY)
      end

      _reset_retries
    end

    def execute(request:)
      _reset_retries
      _validate_request(request)
      _set_auth(request)
      url = _build_uri(request)

      loop do
        access_token = (@authenticator.is_a?(Authenticator::Oauth)) ? @authenticator.access_token : nil
        response_code = nil

        begin
          payload = (Request::HTTP_METHOD_FOR_JSON.include?(request.http_method) && request.headers[:content_type] == :json) ? request.payload.to_json : request.payload
          request.headers[:params] = request.query_params
          response = ::RestClient::Request.execute(method: request.http_method, url:, payload:, headers: request.headers)
          response_code = response&.code
        rescue StandardError => e
          response_code = e.response&.code
          # Any response that doesn't have a status of 200...207 will be raised as an exception from Rest-Client
          raise RestClientError.new("API request encountered an unhandled exception", e.response, e) unless _retry?(response_code)
        end

        return Response.new(response.headers, _parse_response(response), response.code) if Http.success?(response_code)
        raise RestClientNotSuccessful.new("API request was not successful", response) unless _retry?(response_code)

        _wait_and_retry(response_code, access_token)
        next
      end
    end

    def execute_paginated_request(request:, data: true)
      return self.make_request_for_pages({ http_method: request.http_method, uri: request.uri, segment_params: request.segment_params, query_params: request.query_params, headers: request.headers, data: }) # rubocop:disable Metrics/LineLength
    end

    def make_request(http_method:, uri:, payload: {}, segment_params: {}, query_params: {}, headers: {})
      request = Request.new(http_method:, uri:, payload:, segment_params:, query_params:)
      request.headers = headers
      return self.execute(request:)
    end

    def make_request_for_pages(http_method:, uri:, segment_params: {}, query_params: {}, headers: {}, data: false)
      raise RestClientError.new("Paginator not set, unable to make API call", nil, nil) unless @paginator

      @paginator.rest_client ||= self
      return @paginator.paginate(http_method:, uri:, segment_params:, query_params:, headers:, data:)
    end

    private

    def _set_auth(request)
      return if @authenticator.nil?

      auth = (@authenticator.respond_to?(:generate_auth)) ? @authenticator.generate_auth : {}
      if @authenticator.is_a?(Authenticator::Custom)
        case @authenticator.type
        when :query_param
          request.query_params.merge!(auth)
        when :header
          request.headers.merge!(auth)
        end
      else
        request.headers.merge!(auth)
      end
    end

    def _build_uri(request)
      uri = format(request.uri, request.segment_params)
      parsed_uri = URI.parse(uri)
      raise ArgumentError, "URL host does not match config host of instance, unable to make API call" if parsed_uri.absolute? && @host.casecmp("#{ parsed_uri.scheme }://#{ parsed_uri.host }").nonzero?

      return (parsed_uri.absolute?) ? uri : "#{ @host }#{ uri }"
    end

    def _validate_request(request)
      # Regex to find segments in uri with the pattern <segment_param>
      url_segments = request.uri.scan(/<(.*?)>/).flatten
      url_segments.each do |url_segment|
        raise ArgumentError, "Segment parameter not provided for #{ url_segment }. URI #{ request.uri }" unless request.segment_params.include? url_segment.to_sym
      end
      return true
    end

    def _parse_response(response)
      return nil unless response.respond_to?(:body)

      parsed_body =
        case MIME::Types[response&.headers&.[](:content_type)].first
        when "application/json"
          _parse_json(response)
        else
          response.body
        end

      return parsed_body
    rescue StandardError => e
      raise RestClientError.new("Response could not be parsed", response, e)
    end

    def _parse_json(response)
      return { ok: true } if response.body == "ok".to_json # Handle special case for Echo delete responses

      return JSON.parse(response.body, { object_class: Hash, symbolize_names: true })
    rescue StandardError
      return response.body
    end

    def _reset_retries
      @retry_configs.each_value { |v| v[:retry] = 0 }
    end

    def _retry?(response_code)
      return true if @retry_configs.key?(response_code) && @retry_configs[response_code][:retry] < @retry_configs[response_code][:max_retry]

      return false
    end

    def _wait_and_retry(response_code, access_token)
      sleep(@retry_configs[response_code][:wait].to_f)
      Authenticator::Oauth.authenticate(client_id: @authenticator&.client_id, access_token:) if Http.unauthorized?(response_code) && @authenticator.is_a?(Authenticator::Oauth)
      @retry_configs[response_code][:retry] += 1
    end

  end

end
