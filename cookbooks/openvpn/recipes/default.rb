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
  not_if  "cat /etc/network/interfaces | grep -q '#{line}'"
end

directory "/etc/openvpn/easy-rsa" do
  action :create
  owner  "root"
  group  "admin"
end

execute "copy easy-rsa files" do
  command "cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* /etc/openvpn/easy-rsa"
  not_if  "test -f /etc/openvpn/easy-rsa/openssl.cnf"
end

template "/etc/openvpn/easy-rsa/vars" do
  source "vars.erb"
  mode   0755
end

template "/etc/openvpn/easy-rsa/create-server-ca" do
  source "create-server-ca.erb"
  mode   0755
end

execute "setup server CA" do
  command "/etc/openvpn/easy-rsa/create-server-ca"
  creates "/etc/openvpn/server.crt"
end

template "/etc/openvpn/up.sh" do
  source "up.sh.erb"
  mode 0755
end

template "/etc/openvpn/down.sh" do
  source "down.sh.erb"
  mode 0755
end

