extend MesosCookbook::Helpers

zkNodes = getZookeeperNodes
zkUrl = genZkURL(zkNodes, node['mesos']['config']['master']['zookeeper_path'])

remote_file '/usr/bin/mesos-dns' do
  source "https://github.com/mesosphere/mesos-dns/releases/download/#{node['mesos']['config']['mesos-dns']['version']}/mesos-dns-#{node['mesos']['config']['mesos-dns']['version']}-linux-amd64"
  action :create
  mode 0o755
  not_if { ::File.exist?('/usr/bin/mesos-dns') }
end

directory '/etc/mesos-dns' do
  action :create
end

template '/etc/mesos-dns/config.json' do
  source 'mesos-dns/config.json'
  action :create

  variables(
    zkUrl: zkUrl,
    resolvers: node['mesos']['config']['mesos-dns']['resolvers'].collect { |x| "\"#{x}\"" }.join(','),
    ip_sources: node['mesos']['config']['mesos-dns']['IPSources'].collect { |x| "\"#{x}\"" }.join(',')
  )

  notifies :restart, 'service[mesos-dns]', :delayed
end

execute 'systemd_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/usr/lib/systemd/system/mesos-dns.service' do
  source 'mesos-dns/mesos-dns.service'
  action :create
  notifies :run, 'execute[systemd_reload]', :immediately
end

service 'mesos-dns' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end
