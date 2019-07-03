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

require_relative "auth"

module RestClientWrapper

  # Authenticator
  module Authenticator

    # Custom
    class Custom

      include Auth

      attr_reader :type

      TYPE = %i[header query_param].freeze

      def initialize(type:, auth_param:)
        self.type = type
        self.auth_param = auth_param
      end

      def generate_auth
        return @auth_param
      end

      def type=(type)
        raise TypeError, "Request type parameter is not a symbol" unless type.is_a?(Symbol)
        raise ArgumentError, "Not a valid http method" unless TYPE.include?(type)

        @type = type
      end

      def auth_param=(auth_param)
        raise TypeError, "Request auth_param is not a hash" unless auth_param.is_a?(Hash)

        @auth_param = auth_param
      end

    end

  end

end
