module MesosCookbook
  module Marathon
    class MarathonNode < Chef::Resource
      require_relative 'helpers'
      include Helpers

      resource_name :marathon_node
      provides :marathon_node

      property :cluster_name, String, name_property: true
      property :zk_nodes, Array, required: true
      property :zk_path, String, default: 'marathon'
      property :zk_mesos_path, String, default: 'mesos'

      default_action :install

      action :install do
        package 'marathon' do
          action :install
        end

        directory '/etc/marathon/conf' do
          action :create
          recursive true
        end

        file '/etc/marathon/conf/master' do
          content genZkURL(zk_nodes, zk_mesos_path)
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[marathon]', :delayed
        end

        file '/etc/marathon/conf/zk' do
          content genZkURL(zk_nodes, zk_path)
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
      end
    end
  end
end
