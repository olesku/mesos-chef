package 'docker' do
  action :install
end

service 'docker' do
  supports restart: true, reload: true
  action [:enable, :start]
end
