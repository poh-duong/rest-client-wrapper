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

require "colorize"
require "date"

GEM_NAME = "rest-client-wrapper".freeze
GEM_VERSION = "5.0.0".freeze

GEM_FILENAME = "#{ GEM_NAME }-#{ GEM_VERSION }.gem".freeze
GEM_SPEC = "#{ GEM_NAME }.gemspec".freeze
GEMS_URL = "https://rubygems.org/".freeze

def ask_secret(prompt)
  print prompt
  $stdin.noecho(&:gets).tap { $stdout.puts }.chomp
end

desc "Build gem"
task :gem_build do
  puts "Building gem #{ GEM_NAME } ...".green.bold
  system "gem build #{ GEM_NAME }.gemspec"
end
