module MesosCookbook
  module Helpers
    def isNodeType(nodeType)
      node['mesos'][nodeType] == true ? true : false
    end

    def getNodes(nodeType)
      # This should be set if we have made a call to getNodes earlier this run.
      if defined?(['mesos']['nodes'][nodeType])
        return node['mesos']['nodes'][nodeType]
      end

      node.default['mesos']['nodes'][nodeType] = []
      if isNodeType(nodeType)
        node.default['mesos']['nodes'][nodeType] << {
          ipaddress: getIP(node),
          hostname: node[:hostname]
        }
      end

      search(:node, "mesos_#{nodeType}:true AND mesos_clusterName:#{node['mesos']['clusterName']}").each do |n|
        node.default['mesos']['nodes'][nodeType] << {
          ipaddress: getIP(n),
          hostname: n[:hostname]
        }
      end

      node.default['mesos']['nodes'][nodeType].uniq!
      node.default['mesos']['nodes'][nodeType].sort! do |x, y|
        x[:ipaddress] <=> y[:ipaddress]
      end

      node['mesos']['nodes'][nodeType]
    end

    def getNodeCount(nodeType)
      getNodes(nodeType).length
    end

    def getMyId(nodeType)
      getNodes(nodeType) unless defined?(node['mesos']['nodes'][nodeType])

      node['mesos']['nodes'][nodeType].each_with_index do |n, i|
        return i + 1 if n[:ipaddress].eql?(getIP(node))
      end

      Chef::Application.fatal!("Could not get #{nodeType} myid for #{getIP(node)}.")
    end

    def getIP(n)
      n['config']['ip']
    end

    def getZookeeperNodes
      nodes = []
      getNodes('zookeeper').each do |n|
        nodes << "#{n[:ipaddress]}:2181"
      end

      nodes
    end

    def getMyZookeeperId
      getMyId('zookeeper')
    end

    def getZkQuorum
      (getNodeCount('zookeeper') * 0.5).ceil
    end

    def genZkURL(nodes, path)
      "zk://#{nodes.join(',')}/#{path}"
    end

    def getEtcdNodes
      getNodes('etcd')
    end
  end
end
