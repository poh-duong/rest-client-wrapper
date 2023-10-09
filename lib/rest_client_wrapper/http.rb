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

  # Http
  module Http

    SUCCESS_STATUS_CODES = {
      200 => "OK",
      201 => "Created",
      202 => "Accepted",
      203 => "Non-Authoritative Information",
      205 => "No Content",
      206 => "Partial Content",
      207 => "Multi-Status"
    }.freeze

    # success
    def self.success?(code)
      return !SUCCESS_STATUS_CODES[code].nil?
    end

    # 200
    def self.ok?(code)
      return code == Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
    end

    # 400
    def self.bad_request?(code)
      return code == Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_request]
    end

    # 401
    def self.unauthorized?(code)
      return code == Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized]
    end

    # 404
    def self.not_found?(code)
      return code == Rack::Utils::SYMBOL_TO_STATUS_CODE[:not_found]
    end

    # 429
    def self.too_many_requests?(code)
      return code == Rack::Utils::SYMBOL_TO_STATUS_CODE[:too_many_requests]
    end

  end

end
