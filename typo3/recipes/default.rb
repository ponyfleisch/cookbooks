#
# Cookbook Name:: typo3
# Recipe:: default
#
# Copyright 2013, Claudio Mettler
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

remote_file "#{Chef::Config[:file_cache_path]}/typo3-src-#{node['typo3']['version']}.tar.gz" do
  source node['typo3']['file']
end

directory "#{node['typo3']['root']}/typo3_src/" do
  owner "root"
  group "root"
  mode 0755
  recursive true
  action :create
end


directory "#{node['typo3']['root']}/uploads/" do
  owner "root"
  group "root"
  mode 0777
  action :create
end


directory "#{node['typo3']['root']}/typo3temp/" do
  owner "root"
  group "root"
  mode 0777
  action :create
end

bash 'extract typo3 source' do
  extract_path = "#{node['typo3']['root']}/typo3_src/typo3_src-#{node['typo3']['version']}"

  cwd "#{node['typo3']['root']}/typo3_src/"
  code <<-EOH
    tar xzf #{Chef::Config[:file_cache_path]}/typo3-src-#{node['typo3']['version']}.tar.gz
    EOH
  not_if { ::File.exists?(extract_path) }
end

link "#{node['typo3']['root']}/index.php" do
  to "#{node['typo3']['root']}/typo3_src/typo3_src-#{node['typo3']['version']}/index.php"
end

link "#{node['typo3']['root']}/typo3" do
  to "#{node['typo3']['root']}/typo3_src/typo3_src-#{node['typo3']['version']}/typo3/"
end

link "#{node['typo3']['root']}/t3lib" do
  to "#{node['typo3']['root']}/typo3_src/typo3_src-#{node['typo3']['version']}/t3lib/"
end

bash 'create db' do
  code <<-EOH
    mysql -u root --password=#{node['mysql']['server_root_password']} -e "CREATE DATABASE IF NOT EXISTS #{node['typo3']['dbname']}"
    mysql -u root --password=#{node['mysql']['server_root_password']} -e "GRANT ALL ON #{node['typo3']['dbname']}.* TO #{node['typo3']['dbuser']}@localhost IDENTIFIED BY '#{node['typo3']['dbpasswd']}'"
    EOH
end

bash 'install db' do
  code <<-EOH
    mysql -u root --password=#{node['mysql']['server_root_password']} #{node['typo3']['dbname']} < #{node['typo3']['dumpfile']}
    EOH
  not_if { node['typo3']['db_installed'] }
  node.default['typo3']['db_installed'] = true
end



