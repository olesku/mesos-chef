extend MesosCookbook::Helpers

etcdNodes = []
getNodes('etcd').each do |n|
  etcdNodes << sprintf('%s=http://%s:2380', n[:hostname], n[:ipaddress])
end

proxy = isNodeType('etcd_proxy') ? 'on' : 'off'

execute 'unpack_etcd' do
  command "mkdir -p /tmp/etcd &&
  tar xzf /tmp/etcd-#{node['mesos']['config']['etcd']['version']}.tar.gz -C /tmp/etcd --strip-components=1"
  action :nothing
  notifies :run, 'execute[install_etcd]', :immediately
end

execute 'install_etcd' do
  command "cp -f /tmp/etcd/etcd /usr/bin &&
  cp -f /tmp/etcd/etcdctl /usr/bin &&
  rm -rf /tmp/etcd &&
  rm -f /tmp/etcd-#{node['mesos']['config']['etcd']['version']}.tar.gz"
  action :nothing
end

remote_file "/tmp/etcd-#{node['mesos']['config']['etcd']['version']}.tar.gz" do
  source "https://github.com/coreos/etcd/releases/download/#{node['mesos']['config']['etcd']['version']}/etcd-#{node['mesos']['config']['etcd']['version']}-linux-amd64.tar.gz"
  action :create
  not_if { ::File.exist?('/usr/bin/etcd') }
  notifies :run, 'execute[unpack_etcd]', :immediately
end

user 'etcd' do
  shell '/sbin/nologin'
  action :create
end

directory '/etc/etcd' do
  action :create
  owner 'etcd'
  mode 0o775
end

directory '/var/lib/etcd' do
  action :create
  recursive true
  owner 'etcd'
  mode 0o775
end

directory '/var/lib/etcd/data' do
  action :create
  recursive true
  owner 'etcd'
  mode 0o775
end

directory '/var/lib/etcd/wal' do
  action :create
  recursive true
  owner 'etcd'
  mode 0o775
end

ip = getIP(node)

template '/etc/etcd/etcd.conf.yml' do
  source 'etcd/etcd.conf.yml'
  owner 'etcd'
  mode 0o644
  action :create
  variables(node_name: node[:hostname],
            cluster_token: node['mesos']['clusterName'],
            member_nodes: etcdNodes.join(','),
            self_ip: ip,
            proxy: proxy)

  notifies :restart, 'service[etcd]', :delayed
end

execute 'systemd_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/usr/lib/systemd/system/etcd.service' do
  source 'etcd/etcd.service'
  action :create
  notifies :run, 'execute[systemd_reload]', :immediately
end

service 'etcd' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end
