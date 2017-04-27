#
# Cookbook:: tomcat-chef
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package 'java-1.7.0-openjdk-devel'

# Create the group chef and add user chef
group 'chef'

# Create the user Chef
user 'chef' do
  group 'chef'
  action :create
end

# Create the tomcat directory
directory '/opt/tomcat' do
  recursive true
  mode '0770'
  action :create
end

# Creaate the user and group tomcat
group 'tomcat'

user 'tomcat' do
  group 'tomcat'
  shell '/bin/false'
  home '/opt/tomcat'
  action :create
end

# Download the Tomcat Binary and move to /tmp
remote_file 'apache-tomcat-8.0.33.tar.gz' do
  source 'http://www-us.apache.org/dist/tomcat/tomcat-8/v8.0.43/bin/apache-tomcat-8.0.43.tar.gz'
  path '/tmp/apache-tomcat-8.0.33.tar.gz'
  action :create
end

# Extract the file
execute 'extract_tomcat' do
  command 'tar xvf apache-tomcat-8.0.33.tar.gz -C /opt/tomcat --strip-components=1'
  cwd '/tmp'
end

# Create the tomcat/conf directory
directory '/opt/tomcat/conf' do
  group 'chef'
  mode '0770'
  action :create
end

# Update the Permissions
execute 'tomcat_conf' do
  command 'chgrp -R tomcat /opt/tomcat'
  cwd '/opt/tomcat'
end
execute 'chmod_conf_2' do
  command 'chmod -R g+r conf/*'
  cwd '/opt/tomcat'
end
execute 'chmod_conf' do
  command 'chmod g+rwx conf'
  cwd '/opt/tomcat'
end
execute 'chown_tomcat' do
  command 'chown -R tomcat webapps/ work/ temp/ logs/'
  cwd '/opt/tomcat'
end

# Install the systemd unit file
template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
end

# Reload Systemd to load the Tomcat Unit file
execute 'load_tomcat' do
  command 'systemctl daemon-reload'
end

# Start tomcat
execute 'start_tomcat' do
  command 'systemctl start tomcat'
end

# Enable tomcat
execute 'enable_tomcat' do
  command 'systemctl enable tomcat'
end

# Check change firewall to allow port 8080, add if not there
execute 'firewall_add_port' do
  command 'firewall-cmd --zone=public --permanent --add-port=8080/tcp && firewall-cmd --reboot'
  not_if 'cat /etc/services | grep 8080'
end
