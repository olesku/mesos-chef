include_recipe 'mesos::docker'

service 'docker' do
  supports restart: true, reload: true
end

template '/etc/sysconfig/docker-network' do
  source 'calico/docker-network'
  action :create
  notifies :restart, 'service[docker]', :immediately
end

remote_file '/usr/bin/calicoctl' do
  source "https://github.com/projectcalico/calicoctl/releases/download/#{node['mesos']['config']['calico']['version']}/calicoctl"
  action :create
  mode 0o755
  not_if { ::File.exist?('/usr/bin/calicoctl') }
end

execute 'systemd_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

directory '/etc/calico' do
  action :create
end

template '/etc/calico/calico.env' do
  source 'calico/calico.env'
  action :create
  mode 0o644
  notifies :restart, 'service[calico-node]', :delayed
end

template '/usr/lib/systemd/system/calico-node.service' do
  source 'calico/calico-node.service'
  action :create
  notifies :run, 'execute[systemd_reload]', :immediately
end

service 'calico-node' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end
