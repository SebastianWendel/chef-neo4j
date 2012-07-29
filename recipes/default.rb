#
# Cookbook Name:: neo4j
# Recipe:: default
#
# Copyright 2012, SourceIndex IT-Serives
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
when "debian", "ubuntu"
  include_recipe 'apt'
when "centos","redhat"
  include_recipe 'yum'
end

include_recipe "java"

group node['neo4j']['server_group'] do
    #system true
end

user node['neo4j']['server_user'] do
    home node['neo4j']['server_path']
    comment "service user for neo4j-server"
    gid node['neo4j']['server_group']
    #system true
end

root_dirs = [
  node['neo4j']['server_path'],
  node['neo4j']['server_bin'],
  node['neo4j']['server_etc']
]

root_dirs.each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0755"
  end
end

user_dirs = [
  node['neo4j']['server_data'],
  node['neo4j']['server_ssl'],
  node['neo4j']['server_lock'],
  node['neo4j']['server_logs']
]

user_dirs.each do |dir|
  directory dir do
    owner node['neo4j']['server_user']
    group node['neo4j']['server_group']
    mode "0755"
  end
end

unless FileTest.exists?("#{node['neo4j']['server_bin']}/neo4j")
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['neo4j']['server_file']}" do
    source node['neo4j']['server_download']
  end

  execute "install neo4j sources #{node['neo4j']['server_file']}" do
    user "root"
    group "root"
    cwd Chef::Config[:file_cache_path]
    command <<-EOF
      tar -zxf #{node['neo4j']['server_file']}
      chown -R root:root neo4j-community-#{node['neo4j']['server_version']}
      cd neo4j-community-#{node['neo4j']['server_version']}
      mv -f bin/* #{node['neo4j']['server_bin']}
      mv -f doc lib system #{node['neo4j']['server_path']}
    EOF
    action :run
  end
end

link "#{node['neo4j']['server_path']}/data" do
  to node['neo4j']['server_data']
end

link "#{node['neo4j']['server_path']}/conf" do
  to node['neo4j']['server_etc']
end

link "#{node['neo4j']['server_path']}/data/log" do
  to node['neo4j']['server_logs']
end

link "#{node['neo4j']['server_etc']}/ssl" do
  to node['neo4j']['server_ssl']
end

link "/etc/init.d/neo4j-service" do
  to "#{node['neo4j']['server_bin']}/neo4j"
end

template "#{node['neo4j']['server_etc']}/logging.properties" do
  source "logging.properties.erb"
  owner "root"
  group "root"
  mode 0444
end

template "#{node['neo4j']['server_etc']}/neo4j-http-logging.xml" do
  source "neo4j-http-logging.xml.erb"
  owner "root"
  group "root"
  mode 0444
end

template "#{node['neo4j']['server_etc']}/neo4j.properties" do
  source "neo4j.properties.erb"
  owner "root"
  group "root"
  mode 0444
end

template "#{node['neo4j']['server_etc']}/neo4j-server.properties" do
  source "neo4j-server.properties.erb"
  owner "root"
  group "root"
  mode 0444
end

template "#{node['neo4j']['server_etc']}/neo4j-wrapper.conf" do
  source "neo4j-wrapper.conf.erb"
  owner "root"
  group "root"
  mode 0444
end

service "neo4j-service" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action [:enable, :start]
end
