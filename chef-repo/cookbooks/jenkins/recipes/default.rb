#
# Cookbook:: jenkins
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved

#variables reutilizables
jenkins_port    = '8080'


#detectar sistema operativo y mostrarlo
ruby_block 'print_os' do
 block do
    puts "\n viendo sistema operativo\n"
    platform = node['platform']
    puts "\n sistema operativo detectado: #{platform}\n"
  end
end

#instalar docker si no esta instalado( Linux)
if node['platform_family'] == 'debian' || node['platform_family'] == 'rhel'
execute 'install_docker' do 
  puts "\n instalando docker \n" 
  command <<-EOH
    curl -fsSL  https://get.docker.com | sh
  EOH
  not_if 'which docker'
end
end

#detectar si jenkins ya se esta ejecutando y detener
execute 'stop_and_remove_jenkins' do
  command <<-EOH
    sudo docker stop jenkins || true
    sudo docker rm jenkins || true
  EOH
  only_if "docker inspect jenkins >/dev/null 2>&1"
end

#Ejecutar jenkins en Docker
execute 'run_jenkins_container' do
  command <<-EOH
    puts "ejecutando docker-jenkins"
    docker run -d --name jenkins \
    -p #{jenkins_port}:8080 \
    jenkins/jenkins:lts
  EOH
  not_if 'docker ps | grep jenkins'
end

execute 'wait_for_jenkins_container' do
  command <<-EOH
   while ! docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword; do
     sleep 2
   done
  EOH
  retries 10
  retry_delay 3
end

ruby_block 'print_initial_admin_password' do
  block do 
    password = %x(sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword).strip
    puts "\n Jenkins initial admin password: #{password}\n"
  end
end

