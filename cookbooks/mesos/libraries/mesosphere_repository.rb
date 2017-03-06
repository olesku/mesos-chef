module MesosCookbook
  class MesosphereRepository < Chef::Resource
    resource_name :mesosphere_repository
    provides :mesosphere_repository
    default_action :install

    action :install do
      execute "yum -q makecache" do
        action :nothing
      end

      template "/etc/pki/rpm-gpg/RPM-GPG-KEY-mesosphere" do
        source "mesosphere/RPM-GPG-KEY-mesosphere"
        action :create
      end

      template "/etc/yum.repos.d/mesosphere.repo" do
        mode "0644"
        source "mesosphere/mesosphere.repo"
        notifies :run, resources(:execute => "yum -q makecache"), :immediately
      end
    end
  end
end
