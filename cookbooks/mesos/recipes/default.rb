extend MesosCookbook::Helpers

Chef::Application.fatal!('mesos.clusterName is not set!') if node['mesos']['clusterName'].nil?

execute 'yum -q makecache' do
  action :nothing
end

template '/etc/pki/rpm-gpg/RPM-GPG-KEY-mesosphere' do
  source 'mesosphere/RPM-GPG-KEY-mesosphere'
  action :create
end

template '/etc/yum.repos.d/mesosphere.repo' do
  mode '0644'
  source 'mesosphere/mesosphere.repo'
  notifies :run, resources(execute: 'yum -q makecache'), :immediately
end

nodeRecipes = {
  'zookeeper': [ 'mesos::zookeeper' ],
  'master': [ 'mesos::master' ],
  'agent': [ 'mesos::agent' ],
  'etcd': [ 'mesos::etcd' ],
  'etcd_proxy': [ 'mesos::etcd' ],
  'calico': [ 'mesos::calico' ],
  'mesos-dns': [ 'mesos::mesos-dns' ],
  'marathon': [ 'mesos::marathon' ],
  'chronos': [ 'mesos::chronos' ]
}

nodeRecipes.each do |nodeType, recipes|
  if isNodeType(nodeType)
    recipes.each do |r|
      include_recipe r
    end
  end
end
