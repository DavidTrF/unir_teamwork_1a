#
# Cookbook:: jenkins
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.

#iniciar servicio Docker
#deprecate
  #docker_service 'default' do
  #  action [:create, :start]
  #end

#Descargar imagen oficial de Jenkins
#deprecated
 #docker_image 'jenkins/jenkins' do
 # tag 'lts'
 # action :pull
 #end

#crear contenedor Jenkins
#deprecated
 #docker_container 'jenkins' do
  #repo 'jenkins/jenkins'
  #tag 'lts'
  #port ['8080:8080', '50000:50000']
  #restart_policy 'always'
  #volumes ['/var/jenkins_home']
 #end

#variables reutilizables
admin_user      = 'admin'
admin_password  = 'MySecret123'
jenkins_port    = '8080'


#detectar sistema operativo y mostrarlo
ruby_block 'print_os' do
 block do
    platform = node['platform']
    puts "\n sistema operativo detectado: #{platform}"
  end
end

#instalar docker si no esta instalado( Linux)
if node['platform_family'] == 'debian' || node['platform_family'] == 'rhel'
execute 'install_docker' do
  
  command <<-EOH
    curl -fsSL  https://get.docker.com | sh
  EOH
  not_if 'which docker'
end
end

#detectar si jenkins ya se esta ejecutando y detener
execute 'stop_and_remove_jenkins' do
  command <<-EOH
    docker stop jenkins || true
    docker rm jenkins || true
  EOH
  only_if 'docker ps -a --format "{{.names}}" | grep -w jenkins'
end

#Ejecutar jenkins en Docker
execute 'run_jenkins_container' do
  command <<-EOH
    echo "ejecutando docker-jenkins"
    docker run -d --name jenkins \
    -e JAVA_OPT="-Djenkins.install.runSetupWizard=false" \
    -e JENKINS_ADMIN_ID=#{admin_user} \
    -e JENKINS_ADMIN_PASSWORD=#{admin_password} \
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
    password = 'docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'.strip
    puts "\n Jenkins initial admin password: #{password}\n"
  end
end

#mostrar credenciales  configuradas
ruby_block 'print_admin_credentials' do
 block do
   puts "\n Jenkins configurado con:"
   puts "   Usuario: #{admin_user}"
   puts "   Password: #{admin_password}"
   puts "\n Accede a: http://localhost:#{jenkins_port}\n"
 end
end
   
