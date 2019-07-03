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

FactoryBot.define do
  factory :auth_token_response, { class: OpenStruct } do |f|
    skip_create
    f.status { 200 }
    f.body { "{\"token_type\":\"Bearer\",\"access_token\":\"#{ FactoryBot.build(:token).token }\",\"expires_in\":3600,\"refresh_token\":\"#{ FactoryBot.build(:token).token }\"}" }
    f.headers { { content_type: "application/json; charset=utf-8" } }
  end

  factory :response, { class: OpenStruct } do |f|
    skip_create
    f.status { 200 }
    f.body { "{\"result\":\"success\"}" }
    f.headers { { content_type: "application/json; charset=utf-8" } }
  end

  factory :paginated_response, { class: OpenStruct } do |_f|
    status { 200 }
    body { "{\"result\":\"success\"}" }
    headers do
      { content_type: "application/json; charset=utf-8",
        link:         "" }
    end
  end

  factory :token, { class: OpenStruct } do |f|
    skip_create
    f.token { Faker::Crypto.sha1 }
  end
end
