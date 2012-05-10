maintainer       "Gazzang, Inc."
maintainer_email "eddie.garcia@gazzang.com"
license          "Apache 2.0"
description      "Installs/Configures zNcrypt"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
%w{ apt yum }.each do |cb|
  depends cb
end
%w{ debian ubuntu centos redhat fedora }.each do |os|
  supports os
end

recipe "zncrypt::default", "Installs and configures zNcrypt"

