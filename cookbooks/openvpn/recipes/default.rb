#
# Cookbook Name:: openvpn
# Recipe:: default
#
# Copyright 2009, James Golick
#
# All rights reserved - Do Not Redistribute
#

package "openvpn" do
  action :install
end

package "bridge-utils" do
  action :install
end

execute "Add br interface" do
  line = "auto lo br0"
  command "echo '#{line}' >> /etc/network/interfaces && /etc/init.d/networking restart"
  not_if  "cat /etc/network/interfaces | grep -q #{line}"
end

