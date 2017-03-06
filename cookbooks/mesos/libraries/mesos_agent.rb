module MesosCookbook
  module Mesos
    class MesosAgent < Chef::Resource
      require_relative 'helpers'
      include Helpers

      resource_name :mesos_agent
      provides :mesos_agent

      property :cluster_name, String, name_property: true
      property :zk_nodes, Array, required: true
      property :zk_path, String, default: 'mesos'
      property :containerizers, String, default: 'docker,mesos'
      property :executor_registration_timeout, String, default: '3mins'

      default_action :install

      action :install do
        docker_install cluster_name do
          action :install
        end

        package 'mesos' do
          action :install
        end

        file '/etc/mesos/zk' do
          content genZkURL(zk_nodes, zk_path)
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-slave]', :delayed
        end

        file '/etc/mesos-slave/ip' do
          content getIP(node)
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-slave]', :delayed
        end

        file '/etc/mesos-slave/containerizers' do
          content containerizers
          action :create
          owner 'root'
          group 'root'
          mode 0o644
          notifies :restart, 'service[mesos-slave]', :delayed
        end

        file '/etc/mesos-slave/executor_registration_timeout' do
          content executor_registration_timeout
          action :create
          owner 'root'
          group 'root'
          mode 0o644
        end

        service 'mesos-slave' do
          provider Chef::Provider::Service::Systemd
          action [:enable, :start]
          supports restart: true
        end
      end
    end
  end
end
