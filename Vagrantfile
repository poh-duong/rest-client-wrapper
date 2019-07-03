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

Vagrant.configure(2) do |config|
  config.ssh.forward_agent = true

  config.vm.box = "bento/centos-7.5"
  config.vm.box_version = "201808.24.0"
  config.vm.provision :shell, { path: "vagrant/bootstrap_root.sh" }
  config.vm.provision :shell, { path: "vagrant/bootstrap_user.sh", privileged: false, args: [ENV["USER"]] }
  config.vm.provision :shell, { path: "vagrant/startup.sh", privileged: false, run: "always" }
  config.vm.network :forwarded_port, { host: 3000, guest: 3000, auto_correct: true }
  config.vm.network :forwarded_port, { host: 8808, guest: 8808, auto_correct: true }
end
