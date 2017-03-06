module MesosCookbook
  module Etcd
    class EtcdNode < Chef::Resource
      require_relative 'helpers'
      include Helpers

      resource_name :etcd_node
      provides :etcd_node

      property :cluster_name, String, name_property: true

      property :version, String, default: 'v3.1.0'
      property :nodes, Array, required: true
      property :proxy, kind_of: [TrueClass, FalseClass], default: false

      default_action :install

      action :install do
        etcdNodes = []
        nodes.each do |n|
          etcdNodes << sprintf('%s=http://%s:2380', n[:hostname], n[:ipaddress])
        end

        execute 'unpack_etcd' do
          command "mkdir -p /tmp/etcd &&
          tar xzf /tmp/etcd-#{version}.tar.gz -C /tmp/etcd --strip-components=1"
          action :nothing
          notifies :run, 'execute[install_etcd]', :immediately
        end

        execute 'install_etcd' do
          command "cp -f /tmp/etcd/etcd /usr/bin &&
          cp -f /tmp/etcd/etcdctl /usr/bin &&
          rm -rf /tmp/etcd &&
          rm -f /tmp/etcd-#{version}.tar.gz"
          action :nothing
        end

        remote_file "/tmp/etcd-#{version}.tar.gz" do
          source "https://github.com/coreos/etcd/releases/download/#{version}/etcd-#{version}-linux-amd64.tar.gz"
          action :create
          not_if { ::File.exist?('/usr/bin/etcd') }
          notifies :run, 'execute[unpack_etcd]', :immediately
        end

        user 'etcd' do
          shell '/sbin/nologin'
          action :create
        end

        directory '/etc/etcd' do
          action :create
          owner 'etcd'
          mode 0o775
        end

        directory '/var/lib/etcd' do
          action :create
          recursive true
          owner 'etcd'
          mode 0o775
        end

        directory '/var/lib/etcd/data' do
          action :create
          recursive true
          owner 'etcd'
          mode 0o775
        end

        directory '/var/lib/etcd/wal' do
          action :create
          recursive true
          owner 'etcd'
          mode 0o775
        end

        template '/etc/etcd/etcd.conf.yml' do
          source 'etcd/etcd.conf.yml'
          owner 'etcd'
          mode 0o644
          action :create
          variables(node_name: node[:hostname],
                    cluster_token: cluster_name,
                    member_nodes: etcdNodes.join(','),
                    self_ip: getIP(node),
                    proxy: (proxy == true ? 'on' : 'off'))

          notifies :restart, 'service[etcd]', :delayed
        end

        execute 'systemd_reload' do
          command 'systemctl daemon-reload'
          action :nothing
        end

        template '/usr/lib/systemd/system/etcd.service' do
          source 'etcd/etcd.service'
          action :create
          notifies :run, 'execute[systemd_reload]', :immediately
        end

        service 'etcd' do
          provider Chef::Provider::Service::Systemd
          action [:enable, :start]
          supports restart: true
        end
      end
    end
  end
end
