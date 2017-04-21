Chef::Recipe.send(:include, MesosCookbook::Helpers)

clusterName = node['mesos']['clusterName']

Chef::Application.fatal!('mesos.clusterName is not set!') if clusterName.empty?

mesosphere_repository 'default' do
  action :install
end

if isNodeType('zookeeper')
  zookeeper_node clusterName do
    action :install
    id getMyZookeeperId
    nodes getNodes('zookeeper')
  end
end

if isNodeType('etcd')
  etcd_node clusterName do
    action :install
    nodes getNodes('etcd')
  end
end

if isNodeType('etcd_proxy')
  etcd_node clusterName do
    action :install
    proxy true
    nodes getNodes('etcd')
  end
end

if isNodeType('master')
  mesos_master clusterName do
    action :install
    zk_nodes getZookeeperNodes
    quorum getZkQuorum
  end
end

if isNodeType('agent')
  mesos_agent clusterName do
    action :install
    zk_nodes getZookeeperNodes
  end
end

if isNodeType('marathon')
  marathon_node clusterName do
    action :install
    zk_nodes getZookeeperNodes
  end
end

if isNodeType('chronos')
  chronos_node clusterName do
    action :install
    zk_nodes getZookeeperNodes
  end
end
