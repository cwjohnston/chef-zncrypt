#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Resource:: move
#
# Copyright 2013, Needle, Inc.
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

actions :encrypt, :decrypt
default_action :encrypt

attribute :data_dir,      :kind_of => String, :name_attribute => true
attribute :mount_point,   :kind_of => String, :required => true
attribute :group,         :kind_of => String, :required => true
attribute :passphrase,    :kind_of => String, :required => true
attribute :salt,          :kind_of => [String, NilClass], :default => nil
attribute :auth_string,   :kind_of => [String, NilClass], :default => nil