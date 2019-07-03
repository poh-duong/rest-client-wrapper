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

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rest_client_wrapper/version"

Gem::Specification.new do |s|
  s.name        = "rest-client-wrapper"
  s.version     = RestClientWrapper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["University of Adelaide"]
  s.email       = ["myuni.admin@adelaide.edu.au"]
  s.homepage    = "https://github.com/myuni-admin-uofa/rest-client-wrapper"
  s.summary     = "Rest client wrapper"
  s.description = "Generic REST client wrapper"
  s.license     = "GPL 3.0"
  s.required_ruby_version = ">= 2.4.0"

  s.add_runtime_dependency "json", "~> 1.8", ">= 1.8.3"
  s.add_runtime_dependency "oauth2", "~> 1.2"
  s.add_runtime_dependency "rack", "~> 2.0.5"
  s.add_runtime_dependency "rest-client", "~> 2.0.2"
  s.add_runtime_dependency "typhoeus", "~> 1.0", ">= 1.0.1"

  s.add_development_dependency "colorize", "~> 0.7", ">= 0.7.0"
  s.add_development_dependency "geminabox", "~> 0.13.0"
  s.add_development_dependency "rspec", "~> 3.4", ">= 3.4.0"

  s.metadata["allowed_push_host"] = "https://rubygems.org"

  s.files = Dir.glob("lib/**/*.{rake,rb}") + ["#{ s.name }.gemspec", "README.md"]
  s.test_files    = `find spec/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
end
