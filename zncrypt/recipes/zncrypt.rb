#
# Cookbook Name:: zncrypt
# Recipe:: zncrypt
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

case node['platform']
when "redhat", "centos", "fedora"
 # use the yum cookbook
 include_recipe "yum::yum"
 # Add the Gazzang gpg key and repo, redhat centos fedora
 yum_key "RPM-GPG-KEY-gazzang" do
  url "http://archive.gazzang.com/gpg_gazzang.asc"
  action :add
 end
 yum_repository "gazzang" do
  repo_name "gazzang"
  description "RHEL $releasever - gazzang.com - base"
  url "http://archive.gazzang.com/redhat/stable/$releasever/$basearch"
  key "RPM-GPG-KEY-gazzang"
  action :add
 end
when "ubuntu","debian"
 # use the apt cookbook
 include_recipe "apt::default"
 # Add the Gazzang gpg key and repoi, ubuntu debian
 apt_repository "gazzang" do
  uri "http://archive.gazzang.com/#{node['platform']}/stable"
  distribution node['lsb']['codename']
  components ["main"]
  key "http://archive.gazzang.com/gpg_gazzang.asc"
  action :add
 end
else
 # distro not supported/tested, patches welcome
 exit
end


# zNcrypt requires dkms to dynamically compile the zNcrypt kernel nodule
# in most distributions the package is included in the repo
# on CentOS it may need to be preinstalled, we will use RPM forge
if platform?("centos")
 # use the yum cookbook to add the RPM-GPG-KEY
 yum_key "RPM-GPG-KEY.dag.txt" do
  url "http://apt.sw.be/RPM-GPG-KEY.dag.txt"
  action :add
 end
 # there may be a better way to install using yum_repository,  but this works
 script "install dkms rpm for CentOS" do
  interpreter "bash"
  user "root"
  cwd "/usr/local/src"
  code <<-EOH
  wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
  rpm -ivh --force rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
  EOH
 end
end

# assemble the packages
zncrypt_packages = case node['platform']
when "redhat", "centos", "fedora"
 %w{kernel-devel kernel-headers dkms ezncryptfs ezncrypt}
when "ubuntu", "debian"
 uname = %x(uname -r)
 %W{linux-headers-#{uname} dkms ezncryptfs ezncrypt}
end

# loop to install packages
zncrypt_packages.each do |zncrypt_pack|
  package zncrypt_pack do
    action :install
  end
end

