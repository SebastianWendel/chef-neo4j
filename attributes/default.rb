#
# Author:: Sebastian Wendel
# Cookbook Name:: neo4j
# Attribute:: default
#
# Copyright 2012, SourceIndex IT-Services
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

default['neo4j']['project_url'] = "https://github.com/downloads/neo4j"
default['neo4j']['server_version'] = "0.9.6p1"
default['neo4j']['server_file'] = "neo4j-server-#{node['neo4j']['server_version']}.tar.gz"
default['neo4j']['server_download'] = "#{node['neo4j']['project_url']}/neo4j-server/#{node['neo4j']['server_file']}"
default['neo4j']['server_checksum'] = "8bdddfc2ba9b8537f705f997461bd40d3a4091cd3f2b824622704a62ef1c0b96"

default['neo4j']['server_path'] = "/usr/share/neo4j-server"
default['neo4j']['server_bin'] = "#{node['neo4j']['server_path']}/bin"
default['neo4j']['server_wrapper'] = "#{node['neo4j']['server_path']}/wrapper"
default['neo4j']['server_syslog4j'] = "#{node['neo4j']['server_path']}/syslog4j"
default['neo4j']['server_etc'] = "/etc/neo4j-server"
default['neo4j']['server_pid'] = "/var/run/neo4j-server"
default['neo4j']['server_lock'] = "/var/lock/neo4j-server"
default['neo4j']['server_logs'] = "/var/log/neo4j-server"
default['neo4j']['server_user'] = "neo4j"
default['neo4j']['server_group'] = "neo4j"
default['neo4j']['server_port'] = 5140

default['neo4j']['email_type'] = "smtp"
default['neo4j']['email_host'] = "127.0.0.1"
default['neo4j']['email_tls'] = "true"
default['neo4j']['email_port'] = "25"
default['neo4j']['email_auth'] = "plain"
default['neo4j']['email_user'] = nil
default['neo4j']['email_passwd'] = nil
default['neo4j']['email_address'] = "neo4j@#{node['fqdn']}" 
default['neo4j']['email_domain'] = node['fqdn']
