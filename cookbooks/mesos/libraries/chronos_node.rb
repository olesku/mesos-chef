module MesosCookbook
  module Chronos
    class ChronosNode < Chef::Resource
      require_relative 'helpers'
      include Helpers

      resource_name :chronos_node
      provides :chronos_node

      property :cluster_name, String, name_property: true
      property :zk_nodes, Array, required: true
      property :zk_path, String, default: 'chronos'
      property :zk_mesos_path, String, default: 'mesos'

      default_action :install

      action :install do
        package 'chronos' do
          action :install
        end

        directory '/etc/chronos/conf' do
          action :create
          recursive true
        end

        file '/etc/chronos/conf/master' do
          content genZkURL(zk_nodes, zk_mesos_path)
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[chronos]', :delayed
        end

        file '/etc/chronos/conf/zk_hosts' do
          content zk_nodes.join(',')
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[chronos]', :delayed
        end

        service 'chronos' do
          provider Chef::Provider::Service::Systemd
          action [:enable, :start]
          supports restart: true
        end
      end
    end
  end
end
