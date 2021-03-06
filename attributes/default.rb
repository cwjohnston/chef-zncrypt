#
# Author:: Eddie Garcia (<eddie.garcia@gazzang.com>)
# Cookbook Name:: zncrypt
# Attribute:: default
#
# Copyright 2012, Gazzang, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# All rights reserved - Do Not Redistribute
#

# setup the mount point for zncrypt
default['zncrypt']['zncrypt_mount'] = '/var/lib/ezncrypt/ezncrypted'
# setup the storage directory for zncrypt
default['zncrypt']['zncrypt_storage'] = '/var/lib/ezncrypt/storage'
# the data bag to use for the license pool
default['zncrypt']['license_pool'] = 'zncrypt_license_pool'
