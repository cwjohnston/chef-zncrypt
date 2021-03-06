#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: license
#
# Copyright 2012, Needle, Inc.
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

require 'digest/sha1'

action :activate do

  unless get_zncrypt_license and get_zncrypt_activation

    # construct a hash where we store the license data
    @license_data = {
      'allocated_to' => node['hostname'],
      'passphrase' => @new_resource.passphrase
    }

    unless @new_resource.salt.empty?
      # the salt is optional (also referred to as second passphrase)
      @license_data.merge!({ 'salt' => @new_resource.salt })
    end

    unless @new_resource.license.empty? and @new_resource.activation_code.empty?
      # use license and activation code from LWRP, if they have been passed in
      @license_data.merge!({
        'license' => @new_resource.license,
        'activation_code' => @new_resource.activation_code
      })
    else
      # otherwise, try looking in the data bag for an available license
      ensure_data_bag(@new_resource.data_bag)

      begin
        @available_licenses = search(@new_resource.data_bag, "id:license_index").first['licenses']
      rescue => e
        @available_licenses = { }
        Chef::Log.warn("zncrypt: error loading license index from #{@new_resource.data_bag} data bag")
      end

      if !@available_licenses.empty?
        Chef::Log.debug("zncrypt: found #{@available_licenses.count} available licenses \n" + @available_licenses.inspect)
        # select available licence from the index
        @selected_license = @available_licenses.shift
        @license_data.merge!({
          'license' => @selected_license[0],
          'activation_code' => @selected_license[1]
        })
      elsif @new_resource.allow_trial
        # we haven't been passed a license/activation code, and 
        # there are no available licenses in the bag, so we'll make one.
        # the default license will auto reset every hour if your first registration fails, 
        # try again in an hour or contact sales@gazzang.com
        @license_data.merge!({ 
         'license' => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
         'activation_code' => "123412341234"
        })
      else
        Chef::Log.fatal('zncrypt: failed to locate an available license and allow_trial is false. exiting.')
        raise
      end
    end

    # now we'll generate a unique ID for the license using a sha1 hash
    @license_data.merge!({'id' => Digest::SHA1.hexdigest(@license_data['license']+node['hostname'])})

    # by this point we should have generated a license hash from:
    # a) values passed by the LWRP
    # b) values retrieved from the license index in the data bag
    # c) the dummy license provided by gazzang's own cookbook
    Chef::Log.info("zncrypt license: " + @license_data.inspect)
    Chef::Log.debug("zncrypt available licenses: " + @available_licenses.inspect)

    # now it is time to save our work
    # generate a new license index, now minus the license we just used up.
    @license_index = { 'id' => 'license_index', 'licenses' => @available_licenses }

    # first, we save both the updated license_index and new license data to the data bag
    [ @license_index, @license_data ].each do |lic|
      begin
        Chef::Log.debug("attempting to save #{lic['id']} to data bag #{@new_resource.data_bag}")
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag(@new_resource.data_bag)
        databag_item.raw_data = lic
        databag_item.save
      rescue => e
        Chef::Log.fatal(e)
        raise
      end
    end

    activate_args = "--activate --license=#{@license_data['license']} --activation-code=#{@license_data['activation_code']} --passphrase=#{@license_data['passphrase']}"

    if @license_data['salt']
      activate_args = activate_args + " --passphrase2=#{@license_data['salt']}"
    end

    directory "/var/log/ezncrypt"

    script "activate zncrypt for #{node['hostname']}" do
      interpreter "bash"
      user "root"
      code <<-EOH
      ezncrypt-activate #{activate_args}
      EOH
    end

  else
    Chef::Log.info('zncrypt is already actviated, skipping activation process.')
  end

end
