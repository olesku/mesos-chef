module MesosCookbook
  module Docker
    class DockerInstall < Chef::Resource
      resource_name :docker_install
      provides :docker_install

      default_action :install

      action :install do
        package 'docker' do
          action :install
        end

        service 'docker' do
          supports restart: true, reload: true
          action [:enable, :start]
        end
      end
    end
  end
end
