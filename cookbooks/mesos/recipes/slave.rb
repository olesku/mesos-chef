include_recipe 'mesos::default'
include_recipe 'docker::default'

zooNodes = []
node['master_nodes'].each do |n|
  zooNodes << "#{n}:2181"
end

zoo = zooNodes.join(",")
quorum = (zooNodes.length * 0.5).ceil

template '/etc/mesos/zk' do
  source 'zk'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  variables({
    :zoo => zoo
  })
  notifies :restart, 'service[mesos-slave]', :delayed
end

template '/etc/mesos-slave/containerizers' do
  source 'containerizers'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mesos-slave]', :delayed
end

template '/etc/mesos-slave/ip' do
  source 'ip'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mesos-slave]', :delayed
end

file '/etc/mesos-slave/executor_registration_timeout' do
  content '3mins'
  action :create
  owner 'root'
  group 'root'
  mode 0644
end

service 'mesos-slave' do
  provider Chef::Provider::Service::Systemd
  action [ :enable, :start ]
  supports :restart => true
end
