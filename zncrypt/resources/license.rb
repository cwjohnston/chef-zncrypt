#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Resource:: license
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

actions :activate
default_action :activate

attribute :client,        :kind_of => String, :name_attribute => true
attribute :admin_email,   :kind_of => String
attribute :passphrase,    :kind_of => String, :required => true
attribute :salt,          :kind_of => [String,NilClass], :default => nil
attribute :regmode,       :equal_to => [:classic, :regauth], :default => :classic
attribute :orgname,       :kind_of => String
attribute :authcode,      :kind_of => String
attribute :server,        :kind_of => String, :default => 'https://ztrustee.gazzang.com'
attribute :verify_ssl,    :kind_of => [TrueClass, FalseClass], :default => true
