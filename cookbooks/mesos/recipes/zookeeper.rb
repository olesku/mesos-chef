extend MesosCookbook::Helpers

nodes = getNodes('zookeeper')
myId = getMyZookeeperId

package 'mesosphere-zookeeper' do
  action :install
end

directory '/data/zookeeper' do
  action :create
  recursive true
end

template '/etc/zookeeper/conf/zoo.cfg' do
  action :create
  source 'zookeeper/zoo.conf'
  variables(nodes: nodes,
            id: myId,
            dataDir: node['mesos']['config']['zookeeper']['dataDir'],
            maxClientCnxns: node['mesos']['config']['zookeeper']['maxClientCnxns'],
            tickTime: node['mesos']['config']['zookeeper']['tickTime'],
            initLimit: node['mesos']['config']['zookeeper']['initLimit'],
            syncLimit: node['mesos']['config']['zookeeper']['syncLimit'])

  notifies :restart, 'service[zookeeper]', :immediately
end

file '/data/zookeeper/myid' do
  action :create
  content myId.to_s
  notifies :restart, 'service[zookeeper]', :immediately
end

service 'zookeeper' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
  supports restart: true
end
