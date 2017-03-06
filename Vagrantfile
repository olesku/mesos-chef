require './lib/gen_nodeconfig.rb'
clusterConfig = loadConfig()

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  clusterConfig[:nodes].each do |nodeConfig|
    config.vm.define nodeConfig[:hostname] do |cfg|
      cfg.vm.hostname = nodeConfig[:hostname]
      cfg.vm.box = clusterConfig[:box]

      cfg.vm.provider :virtualbox do |v, override|
        v.gui = false
        v.memory = nodeConfig[:mem]
        v.cpus = nodeConfig[:cpus]
        override.vm.network :private_network, :ip => nodeConfig[:ip]


        override.vm.provision :hostmanager
        override.vm.provision "shell", path: "scripts/bootstrap.sh"

        override.vm.provision :chef_zero do |chef|
          chef.roles_path = "roles"
          chef.nodes_path = "nodes"
          chef.add_role(nodeConfig[:type])

          chef.json = {
            "config": nodeConfig,
            "mesos": {
              "masters": clusterConfig[:masters],
              "agents": clusterConfig[:agents]
            }
          }
        end
      end
    end
  end

  # Router
#  config.vm.define "vyos-router" do |vyos|
#    vyos.vm.box = "higebu/vyos"
#    vyos.vm.hostname = "vyos-router"
#
#  vyos.vm.provider :virtualbox do |v,override|
#      v.memory = 512
#      v.cpus = 1
#      override.vm.network :private_network, :ip => "172.20.2.100"
#    end
#  end
end
