require 'yaml'
require 'pp'

def loadConfig
  base_dir = File.expand_path(File.dirname(__FILE__))
  conf = YAML.load_file(File.join(base_dir, '../cluster.yaml'))

  nodeConfig = {
    box: conf['box'],
    nodes: [],
    masters: [],
    agents: []
  }

  # Master config.
  for i in 1..conf['num_masters'] do
    hostname = sprintf('master-%02d', i)
    ip = sprintf('%s%i', conf['master_network'], (i + 1))

    nodeConfig[:nodes] << {
      master_id: i,
      hostname: hostname,
      type: 'master',
      mem: conf['master_mem'],
      cpus: conf['master_cpus'],
      ip: ip
    }

    nodeConfig[:masters] << ip
  end

  # Agent config.
  for i in 1..conf['num_agents'] do
    hostname = sprintf('agent-%02d', i)
    ip = sprintf('%s%i', conf['agent_network'], (i + 1))

    nodeConfig[:nodes] << {
      agent_id: i,
      hostname: hostname,
      type: 'agent',
      mem: conf['agent_mem'],
      cpus: conf['agent_cpus'],
      ip: ip
    }

    nodeConfig[:agents] << ip
  end

  nodeConfig
end
