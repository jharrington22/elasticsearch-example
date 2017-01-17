#
# Cookbook:: elasticsearch-example-cookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'apt'
include_recipe 'java'
include_recipe 'nginx'

elasticsearch_user 'elasticsearch' do
  username 'elasticsearch'
  groupname 'elasticsearch'
  shell '/bin/bash'
  comment 'Elasticsearch User'
  action :create
end

elasticsearch_install 'elasticsearch' do
  type 'package'
  version "5.1.1"
  action :install
end

elasticsearch_configure 'elasticsearch' do
  allocated_memory '256m'
  configuration ({
  'cluster.name' => 'mycluster',
  'node.name' => 'node01'
  })
end

elasticsearch_service 'elasticsearch' do
  service_actions [:enable, :start]
end

# Setup Basic Auth
ruby_block "add users to passwords file" do
  block do
    require 'webrick/httpauth/htpasswd'
    @htpasswd = WEBrick::HTTPAuth::Htpasswd.new('/etc/nginx/htpasswd')

    @htpasswd.set_passwd( 'Elasticsearch', 'elasticsearch', 'searchelastic' )

    @htpasswd.flush
  end
end

# Add nginx configuration
template "/etc/nginx/sites-available/elasticsearch-proxy.conf" do
  source 'elasticsearch-proxy.conf.erb'
  action :create
  notifies :reload, 'service[nginx]'
end

# Enable site
nginx_site "elasticsearch-proxy" do
  enable true
end
