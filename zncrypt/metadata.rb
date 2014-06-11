name             "zncrypt"
maintainer       "Gazzang, Inc."
maintainer_email "eddie.garcia@gazzang.com"
license          "Apache 2.0"
description      "Installs/Configures zNcrypt 3.x"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.4.1"
%w{ apt openssl java }.each do |cb|
  depends cb
end

depends 'yum', '~> 3.2'
depends 'yum-repoforge'

%w{ debian ubuntu centos redhat fedora }.each do |os|
  supports os
end

recipe "zncrypt::default", "Installs and configures zNcrypt"
recipe "zncrypt::cassandra", "Installs and configures DataStax Cassandra"
recipe "zncrypt::mongodb", "Installs and configures MongoDB"

