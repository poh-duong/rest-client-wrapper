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

require_relative "paginate"
require_relative "../exceptions"

module RestClientWrapper

  # Paginator
  module Paginator

    include Paginate

    # Echo
    class Echo

      attr_accessor :rest_client

      def initialize(limit: Paginate::DEFAULT_PAGINATION_PAGE_SIZE)
        @rest_client = nil
        @config = { limit: }
      end

      def paginate(http_method:, uri:, segment_params: {}, query_params: {}, headers: {}, data: false)
        raise RestClientError.new("Client not set, unable to make API call", nil, nil) unless @rest_client

        query_params.reverse_merge!(@config)
        responses = []
        loop do
          response = @rest_client.make_request(http_method:, uri:, segment_params:, query_params:, headers:)
          (block_given?) ? yield(response) : (responses << response)
          links = _pagination_links(response)
          break unless links.key?(:offset)

          query_params[:offset] = links[:offset]
        end
        return (data) ? responses.map(&:body).pluck(:data).flatten : responses
      end

      private

      def _pagination_links(response)
        next_l = response&.body&.[](:next) || ""
        next_h = Rack::Utils.parse_query(URI.parse(next_l)&.query)
        return next_h.symbolize_keys!
      end

    end

  end

end
