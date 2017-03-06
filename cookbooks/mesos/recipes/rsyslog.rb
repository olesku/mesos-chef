template '/etc/rsyslog.conf' do
  action :create
  source 'rsyslog.conf'
  owner 'root'
  mode '0644'
  notifies :restart, 'service[rsyslog]', :delayed
end

service 'rsyslog' do
  provider Chef::Provider::Service::Systemd
  action [ :enable, :start ]
  supports :restart => true
end
