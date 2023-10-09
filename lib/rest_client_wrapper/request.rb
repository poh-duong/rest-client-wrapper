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

module RestClientWrapper

  # Request
  class Request

    attr_accessor :uri
    attr_reader :headers, :http_method, :payload, :segment_params, :query_params

    DEFAULT_CONTENT_TYPE = { content_type: :json, accept: :json }.freeze # default content type for post and put requests
    VALID_HTTP_METHODS = %i[get post put patch delete connect options trace].freeze
    HTTP_METHOD_FOR_JSON = %i[post put patch].freeze

    def initialize(**params)
      @uri = params[:uri]
      self.headers = (params[:headers].nil?) ? {} : params[:headers]
      self.http_method = params[:http_method]
      self.segment_params = (params[:segment_params].nil?) ? {} : params[:segment_params]
      self.payload = (params[:payload].nil?) ? {} : params[:payload]
      self.query_params = (params[:query_params].nil?) ? {} : params[:query_params]
    end

    def http_method=(http_method)
      raise TypeError, "Request http_method parameters is not a symbol" unless http_method.is_a?(Symbol)
      raise ArgumentError, "Not a valid http method" unless VALID_HTTP_METHODS.include?(http_method)

      headers[:content_type] = DEFAULT_CONTENT_TYPE[:content_type] unless headers.key?(:content_type) || !HTTP_METHOD_FOR_JSON.include?(http_method)
      headers[:accept] = DEFAULT_CONTENT_TYPE[:accept] unless headers.key?(:accept) || !HTTP_METHOD_FOR_JSON.include?(http_method)
      @http_method = http_method
    end

    def payload=(payload)
      raise TypeError, "Request payload parameters is not a hash" if !payload.is_a?(Hash) && self.headers[:content_type] == :json

      @payload = payload
    end

    def segment_params=(segment_params)
      raise TypeError, "Request segment parameters is not a hash" unless segment_params.is_a?(Hash)

      @segment_params = segment_params
    end

    def query_params=(query_params)
      raise TypeError, "Request query parameters is not a hash" unless query_params.is_a?(Hash)

      @query_params = query_params
    end

    def headers=(headers)
      raise TypeError, "Request headers parameters is not a hash" unless headers.is_a?(Hash)

      (@headers.nil?) ? @headers = headers : @headers.merge!(headers)
    end

  end

end
