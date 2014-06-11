#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: license
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

require 'mixlib/shellout'
include ::Gazzang::Zncrypt::Helpers

def license_params_valid?(resource)

  if resource.passphrase.empty?
    Chef::Application.fatal!(
      "zncrypt_license requires a value for the passphrase parameter"
    )
  end

  case resource.regmode
  when :regauth
    if resource.orgname.empty? || resource.authcode.empty?
      Chef::Application.fatal!(
        'zncrypt_license requires org and auth parameters when using regauth regmode'
      )
    end
  when :classic
    if resource.admin_email.empty?
      Chef::Application.fatal!(
        'zncrypt_license requires admin_email parameter when using classic regmode'
      )
    end
  end

  return true
end

def key_type(resource)
  if license_params_valid?(resource)

    passphrase_provided = resource.passphrase.nil? || resource.passphrase.empty? ? false : true
    salt_provided = resource.salt.nil? || resource.salt.empty? ? false : true

    unless passphrase_provided
      Chef::Application.fatal!(
        'zncrypt_license requires a passphrase'
      )
    end

    # if a passphrase is provided without a salt, we are using single-passphrase
    if passphrase_provided && !salt_provided
      return 'single-passphrase'
    end

    # if both a passphrase and a salt are provided, we are using dual-passphrase
    if passphrase_provided && salt_provided
      return 'dual-passphrase'
    else
      Chef::Application.fatal!(
        "Could not determine key type for #{resource}"
      )
    end
  end
end

def register_auth_string(resource)
  case key_type(resource)
  when 'single-passphrase'
    return [resource.passphrase, resource.passphrase].join("\n")
  when 'dual-passphrase'
    return [resource.passphrase, resource.passphrase, resource.salt, resource.salt].join("\n")
  end
end

def activate_auth_string(resource)
  case key_type(resource)
  when 'single-passphrase'
    return "#{resource.passphrase}\n"
  when 'dual-passphrase'
    [resource.passphrase, resource.salt].join("\n")
  end
end

def register_args(resource)
  if license_params_valid?(resource)
    case resource.regmode
    when :regauth
      "--key-type=#{key_type(resource)} --clientname=#{resource.client} \
      --org=#{resource.orgname} --auth=#{resource.authcode}"
    when :classic
      "--key-type=#{key_type(resource)} --clientname=#{resource.client}"
    end
  end
end

def server_args(resource)
  if resource.verify_ssl
    "--server=#{resource.server}"
  else
    "--server=#{resource.server} --skip-ssl-check"
  end
end

action :activate do
  if ::File.exists?('/etc/zncrypt/control') && zncrypt_registered?
    Chef::Log.info(
      'zncrypt is already actviated, skipping activation process.'
    )
  else
    directory '/var/log/zncrypt'

    # the following make use of printf to avoid logging the passphrase
    register_cmd = Mixlib::ShellOut.new(
      "zncrypt register #{register_args(new_resource)} #{server_args(new_resource)}",
      :input => register_auth_string(new_resource),
      :log_level => :debug
    )
    register_cmd.run_command
    register_cmd.error!

    if new_resource.regmode == :classic
      activate_cmd = Mixlib::ShellOut.new(
        "zncrypt request-activation --contact=#{new_resource.admin_email} #{server_args(new_resource)}",
        :input => @activate_auth_string,
        :log_level => :debug
        )
      activate_cmd.run_command
      activate_cmd.error!
    end

    new_resource.updated_by_last_action(true)
  end

end
