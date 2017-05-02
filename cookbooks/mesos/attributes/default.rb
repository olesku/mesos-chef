default['mesos']['clusterName'] = 'my-cluster'

# Master defaults.
default['mesos']['config']['zookeeper_path'] = 'mesos'
default['mesos']['config']['master']['workDir'] = '/var/lib/mesos'

# Agent defaults.
default['mesos']['config']['agent']['containerizers'] = 'docker,mesos'
default['mesos']['config']['agent']['executor_registration_timeout'] = '3mins'

# Zookeeper defaults.
default['mesos']['config']['zookeeper']['dataDir'] = '/data/zookeeper'
default['mesos']['config']['zookeeper']['maxClientCnxns'] = 50
default['mesos']['config']['zookeeper']['tickTime'] = 2000
default['mesos']['config']['zookeeper']['initLimit'] = 10
default['mesos']['config']['zookeeper']['syncLimit'] = 5

# Etcd defaults.
default['mesos']['config']['etcd']['version'] = 'v3.1.0'

# mesos-dns defaults.
default['mesos']['config']['mesos-dns']['version'] = 'v0.6.0'
default['mesos']['config']['mesos-dns']['resolvers'] = ['8.8.8.8', '4.4.4.4']
default['mesos']['config']['mesos-dns']['IPSources'] = %w(netinfo host)

# Calico defaults.
default['mesos']['config']['calico']['version'] = 'v1.1.3'

# Marathon defaults.
default['mesos']['config']['marathon']['zookeeper_path'] = 'marathon'
