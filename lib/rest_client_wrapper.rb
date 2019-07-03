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

# RestClientWrapper
module RestClientWrapper

  require_relative "rest_client_wrapper/authenticators/basic"
  require_relative "rest_client_wrapper/authenticators/custom"
  require_relative "rest_client_wrapper/authenticators/oauth"
  require_relative "rest_client_wrapper/authenticators/token"
  require_relative "rest_client_wrapper/paginators/echo"
  require_relative "rest_client_wrapper/paginators/header_link"
  require_relative "rest_client_wrapper/rest_client"
  require_relative "rest_client_wrapper/http"
  require_relative "rest_client_wrapper/request"
  require_relative "rest_client_wrapper/response"

end
