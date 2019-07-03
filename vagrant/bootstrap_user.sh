#!/usr/bin/env bash
#
# Bootstrap commands to run as the vagrant user

###
# rvm is installed in the base image.  just install the version of ruby used
# by this app, then run bundle install.
###
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -L get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install $(cat /vagrant/.ruby-version) --quiet-curl
rvm use $(cat /vagrant/.ruby-version)
cd /vagrant
gem install bundler
echo "Running bundle install..."
bundle install --quiet

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

###
# User info (params) default to vagrant
###
V_ACTUAL_USER=vagrant
if [ $# -eq 1 ]
  then
    V_ACTUAL_USER=$1
fi
