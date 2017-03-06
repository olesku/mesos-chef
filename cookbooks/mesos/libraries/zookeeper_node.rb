module MesosCookbook
  module Zookeeper
    class ZookeeperNode < Chef::Resource
      require_relative 'helpers'
      include Helpers

      resource_name :zookeeper_node
      provides :zookeeper_node

      property :cluster_name, String, name_property: true
      property :maxClientCnxns, Integer, default: 50
      property :tickTime, Integer, default: 2000
      property :initLimit, Integer, default: 10
      property :syncLimit, Integer, default: 5
      property :dataDir, String, default: '/data/zookeeper'

      property :nodes, Array, required: true
      property :id, Integer, required: true

      default_action :install

      action :install do
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
                    id: id,
                    maxClientCnxns: maxClientCnxns,
                    tickTime: tickTime,
                    initLimit: initLimit,
                    syncLimit: syncLimit,
                    dataDir: dataDir)
          notifies :restart, 'service[zookeeper]', :immediately
        end

        file '/data/zookeeper/myid' do
          action :create
          content id.to_s
          notifies :restart, 'service[zookeeper]', :immediately
        end

        service 'zookeeper' do
          provider Chef::Provider::Service::Systemd
          action [:enable, :start]
          supports restart: true
        end
      end
    end
  end
end
