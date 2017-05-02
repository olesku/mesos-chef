extend MesosCookbook::Helpers

zkNodes = getZookeeperNodes
zkUrl = genZkURL(zkNodes, node['mesos']['config']['zookeeper_path'])
quorum = getZkQuorum
ip = getIP(node)

package 'mesos' do
  action :install
end

file '/etc/mesos/zk' do
  content zkUrl
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/quorum' do
  content quorum.to_s
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/ip' do
  content ip
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/work_dir' do
  content node['mesos']['config']['master']['workDir']
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/cluster' do
  content node['mesos']['clusterName']
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[mesos-master]', :delayed
end

service 'mesos-master' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end

service 'mesos-slave' do
  provider Chef::Provider::Service::Systemd
  action [:disable, :stop]
end
