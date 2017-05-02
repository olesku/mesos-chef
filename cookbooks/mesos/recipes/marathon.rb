extend MesosCookbook::Helpers

zkNodes = getZookeeperNodes
zkMesosUrl = genZkURL(zkNodes, node['mesos']['config']['zookeeper_path'])
zkMarathonUrl = genZkURL(zkNodes, node['mesos']['config']['marathon']['zookeeper_path'])

ip = getIP(node)

package 'marathon' do
  action :install
end

directory '/etc/marathon/conf' do
  action :create
  recursive true
end

file '/etc/marathon/conf/master' do
  content zkMesosUrl
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[marathon]', :delayed
end

file '/etc/marathon/conf/zk' do
  content zkMarathonUrl
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[marathon]', :delayed
end

file '/etc/marathon/conf/default_network_name' do
  content 'calico-default'
  action :create
  owner 'root'
  group 'root'
  mode 0o644
  notifies :restart, 'service[marathon]', :delayed
end

service 'marathon' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end
