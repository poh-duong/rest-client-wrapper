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

    # HeaderLink
    class HeaderLink

      attr_accessor :rest_client

      def initialize(per_page: Paginate::DEFAULT_PAGINATION_PAGE_SIZE)
        @rest_client = nil
        @config = { page: nil, per_page: }
      end

      def paginate(http_method:, uri:, segment_params: {}, query_params: {}, headers: {}, data: false)
        raise RestClientError.new("Client not set, unable to make API call", nil, nil) unless @rest_client

        query_params.reverse_merge!(@config)
        responses = []
        loop.with_index(1) do |_, page|
          query_params[:page] = page
          response = @rest_client.make_request(http_method:, uri:, segment_params:, query_params:, headers:)
          (block_given?) ? yield(response) : (responses << response)
          links = _pagination_links(response)
          break unless links.key?(:next)
        end
        return (data) ? responses.map(&:body).flatten : responses
      end

      private

      def _pagination_links(response) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        re_uri = "<(.*?)>".freeze
        re_rel = "current|next|first|last".freeze
        links_a = response&.headers&.[](:link)&.split(",") || []
        links_h = {}
        links_a.each do |rel_link|
          link_parts = rel_link.split(";")
          next unless link_parts.length == 2

          uri_match = link_parts[0].match(re_uri)
          rel_match = link_parts[1].match(re_rel)
          next if (uri_match.nil? || rel_match.nil?) || (uri_match.captures.length != 1 || rel_match.length != 1)

          links_h[rel_match[0]] = uri_match.captures[0]
        end
        return links_h.symbolize_keys!
      end

    end

  end

end
