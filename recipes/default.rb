#
# Cookbook Name:: neo4j
# Recipe:: server
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

include_recipe "java"
include_recipe "logrotate"

group node['neo4j']['server_group'] do
    system true
end

user node['neo4j']['server_user'] do
    home node['neo4j']['server_path']
    comment "services user for neo4j-server"
    gid node['neo4j']['server_group']
    system true
end

root_dirs = [
  node['neo4j']['server_path'],
  node['neo4j']['server_bin'],
  node['neo4j']['server_wrapper'],
  node['neo4j']['server_path'],
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
  node['neo4j']['server_pid'],
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

unless FileTest.exists?("#{node['neo4j']['server_bin']}/neo4j-server.jar")
  remote_FILE "#{Chef::Config[:file_cache_path]}/#{node['neo4j']['server_file']}" do
    source node['neo4j']['server_download']
    checksum node['neo4j']['server_checksum']
    action :create_if_missing
  end

  bash "install neo4j sources #{node['neo4j']['server_file']}" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      tar -zxf #{node['neo4j']['server_file']}
      rm -rf neo4j-server-#{node['neo4j']['server_version']}/build_date neo4j-server-#{node['neo4j']['server_version']}/bin neo4j-server-#{node['neo4j']['server_version']}/neo4j.conf.example
      mv -f neo4j-server-#{node['neo4j']['server_version']}/* #{node['neo4j']['server_bin']}
    EOH
  end
end

unless FileTest.exists?("#{node['neo4j']['server_wrapper']}/lib/wrapper.jar")
  remote_FILE "#{Chef::Config[:file_cache_path]}/#{node['neo4j']['servicewrapper_file']}" do
    source node['neo4j']['servicewrapper_download']
    checksum node['neo4j']['servicewrapper_checksum']
    action :create_if_missing
  end

  bash "extract java service wrapper" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      tar -zxf #{node['neo4j']['servicewrapper_file']} 
      rm -rf wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/conf wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/src wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/jdoc wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/doc wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/logs wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/jdoc.tar.gz wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/bin/*.exe wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/bin/*.bat wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/lib/*.dll wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/lib/*demo*.* wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/bin/*test*.*
      mv wrapper-delta-pack-#{node['neo4j']['servicewrapper_version']}/* #{node['neo4j']['server_wrapper']}
    EOH
  end
end

link "#{node['neo4j']['server_path']}/config" do
  to node['neo4j']['server_etc']
end

link "#{node['neo4j']['server_path']}/logs" do
  to node['neo4j']['server_logs']
end

template "/etc/init.d/neo4j-server" do
  source "neo4j-server-init.erb"
  owner "root"
  group "root"
  mode 0755
end

template "#{node['neo4j']['server_etc']}/neo4j-wrapper.conf" do
  source "neo4j-server-wrapper.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node['neo4j']['server_etc']}/neo4j-server.conf" do
    source "neo4j-server.conf.erb"
    mode 0644
end

template "/etc/init.d/neo4j-server" do
    source "neo4j-server-init.erb"
    owner "root"
    group "root"
    mode 0755
end

logrotate_app "neo4j-server" do
  cookbook "logrotate"
  path "#{node['neo4j']['server_logs']}/neo4j.log"
  frequency "daily"
  rotate 30
  create "644 root adm"
end

service "neo4j-server" do
  supports :restart => true
  action [:enable, :start]
end
