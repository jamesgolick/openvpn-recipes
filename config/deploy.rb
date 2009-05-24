require 'activesupport'

role :host,             "integrity.giraffesoftlabs.com"

set :user,                  "james"
set :cookbook_path,         "/var/chef/cookbooks"
set :cookbooks_archive,     "/home/#{user}/cookbooks.tar.gz"
set :cookbook_staging_path, "/home/#{user}/cookbooks.tar.gz"
set :json_staging_path,     "/home/#{user}/dna.json"
set :chef_bin,              "/usr/bin/chef-solo"
set :path_to_dna,           "/etc/chef/dna.json"
set :cookbooks,             %w( openvpn )

task :sync_cookbooks do
  sudo "mkdir -p #{cookbook_path}"
  `tar --file=build/cookbooks.tar.gz -czv cookbooks`
  put  File.read("build/cookbooks.tar.gz"), cookbooks_archive
  sudo "rm -Rf #{cookbook_staging_path}"
  run  "tar zxvf #{cookbooks_archive}"
  sudo "cp -R #{cookbook_staging_path} /var/chef"
end

task :write_json do
  sudo "mkdir -p /etc/chef"
  put({:cookbooks => cookbooks}.to_json, json_staging_path)
  sudo "mv #{json_staging_path} #{path_to_dna}"
end

task :run_chef do
  sudo "#{chef-bin} -j #{path_to_dna}"
end

task :bootstrap do
  sudo "test -f #{chef_bin} || sudo gem install chef --source http://gems.rubyforge.org --source http://gems.opscode.com"
end

before :run_chef, :bootstrap, :sync_cookbooks, :write_json

