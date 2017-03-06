module MesosCookbook
  module Mesos
    class MesosMaster < Chef::Resource
      require_relative 'helpers'
      include Helpers

      resource_name :mesos_master
      provides :mesos_master

      property :cluster_name, String, name_property: true
      property :zk_nodes, Array, required: true
      property :zk_path, String, default: 'mesos'
      property :quorum, Integer, required: true
      property :work_dir, String, default: '/var/lib/mesos'

      default_action :install

      action :install do
        package 'mesos' do
          action :install
        end

        file '/etc/mesos/zk' do
          content genZkURL(zk_nodes, zk_path)
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-master]', :delayed
        end

        file '/etc/mesos-master/quorum' do
          content quorum.to_s
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-master]', :delayed
        end

        file '/etc/mesos-master/ip' do
          content getIP(node)
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-master]', :delayed
        end

        file '/etc/mesos-master/work_dir' do
          content work_dir
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-master]', :delayed
        end

        file '/etc/mesos-master/cluster' do
          content cluster_name
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-master]', :delayed
        end

        service 'mesos-master' do
          provider Chef::Provider::Service::Systemd
          action [:enable, :start]
          supports restart: true
        end
      end
    end
  end
end
