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
  factory :request, { class: OpenStruct } do |f|
    skip_create
    f.body    { FactoryBot.build(:request_body).to_h }
    f.headers { FactoryBot.build(:request_headers).to_h }
  end

  factory :oauth_token_request, { class: OpenStruct } do |f|
    skip_create
    f.body    { FactoryBot.build(:oauth_request_body).to_h }
    f.headers { FactoryBot.build(:request_headers).to_h }
  end

  factory :oauth_request_body, { class: OpenStruct } do |f|
    skip_create
    f.client_id     { "client_id" }
    f.client_secret { "client_secret" }
    f.grant_type    { "client_credentials" }
  end

  factory :request_body, { class: OpenStruct } do |f|
    skip_create
    f.course_id { Faker::Hipster.sentence(5) }
  end

  factory :request_headers, { class: OpenStruct } do |f|
    skip_create
    f.host { "fake_oauth_token.com" }
  end
end
