maintainer        "Sebastian Wendel, SourceIndex IT-Services"
maintainer_email  "packages@sourceindex.de"
license           "Apache 2.0"
description       "Installs and configures neo4j"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.0"
recipe            "neo4j", "Installs and configures neo4j"

%w{apt yum java}.each do |pkg|
  depends pkg
end

%w{redhat centos ubuntu debian}.each do |os|
  supports os
end
