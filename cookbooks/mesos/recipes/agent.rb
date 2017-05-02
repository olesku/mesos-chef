extend MesosCookbook::Helpers

zkNodes = getZookeeperNodes
zkUrl = genZkURL(zkNodes, node['mesos']['config']['zookeeper_path'])
ip = getIP(node)

include_recipe 'mesos::docker'

package 'mesos' do
  action :install
end

file '/etc/mesos/zk' do
  content zkUrl
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-slave]', :delayed
end

file '/etc/mesos-slave/ip' do
  content ip
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-slave]', :delayed
end

file '/etc/mesos-slave/containerizers' do
  content node['mesos']['config']['agent']['containerizers']
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-slave]', :delayed
end

file '/etc/mesos-slave/executor_registration_timeout' do
  content node['mesos']['config']['agent']['executor_registration_timeout']
  action :create
  owner 'root'
  group 'root'
  mode 0o644
end

service 'mesos-slave' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end

service 'mesos-master' do
  provider Chef::Provider::Service::Systemd
  action [:disable, :stop]
end
