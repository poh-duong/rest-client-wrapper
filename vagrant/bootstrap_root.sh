#!/usr/bin/env bash

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

#
# Bootstrap commands to run as root in the new VM, which are not already in
# the rails image.  For example, if you have an application specific RPM to
# install, do it here.

# install dependencies
yum install --assumeyes epel-release

# install dependencies for rvm
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel sqlite-devel
