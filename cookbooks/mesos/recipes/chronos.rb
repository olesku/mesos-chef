package 'chronos' do
  action :install
end

directory '/etc/chronos/conf' do
  action :create
  recursive true
end

# file '/etc/chronos/conf/master' do
#  content genZkURL(zk_nodes, zk_mesos_path)
#  action :create
#  owner 'root'
#  group 'root'
#  mode 0o644
#  notifies :restart, 'service[chronos]', :delayed
# end

# file '/etc/chronos/conf/zk_hosts' do
#  content zk_nodes.join(',')
#  action :create
#  owner 'root'
#  group 'root'
#  mode 0o644
#  notifies :restart, 'service[chronos]', :delayed
# end

service 'chronos' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end
