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
  notifies :restart, 'service[mesos-master]', :delayed
end

template '/etc/mesos-master/quorum' do
  source 'quorum'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  variables({
    :quorum => quorum
  })
  notifies :restart, 'service[mesos-master]', :delayed
end

template '/etc/mesos-master/ip' do
  source 'ip'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mesos-master]', :delayed
end

template '/etc/mesos-master/work_dir' do
  source 'work_dir'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mesos-master]', :delayed
end

template '/etc/mesos-master/cluster' do
  source 'cluster'
  action :create
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mesos-master]', :delayed
end

service 'mesos-master' do
  provider Chef::Provider::Service::Systemd
  action [ :enable, :start ]
  supports :restart => true
end
