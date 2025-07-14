#Receta que instala dependencias (Solo MacOS), clona un repositorio, construye un jar y corre un aplicacion de java


#Se define el url del repositorio publico de github
REPO_URL = "https://github.com/spring-guides/gs-spring-boot.git"
#Se define como se llamara la app de springboot
APP_NAME = "your-springboot-api"
#Se define el directorio donde se clonara el repo
APP_DIR = "#{ENV['HOME']}/#{APP_NAME}"
#Se define el sub-directorio donde se encuentra el archivo pom.xml dentro del repositorio (en el caso del repositorio de ejemplo, se encuentra en /complete/)
APP_SUBDIR = "#{APP_DIR}/complete"


#Instalamos las dependencias usando brew
 homebrew_package 'git' do    
  action :install  
end
 homebrew_package 'openjdk' do    
  action :install  
end
 homebrew_package 'maven' do    
  action :install  
end


# Clonamos el repositorio de la rama main
git APP_DIR do
  repository REPO_URL
  revision 'main'  
  action :sync
end

# Construimos el JAR usando maven
execute 'build spring boot app' do
  cwd APP_SUBDIR
  command 'mvn clean package -DskipTests'
end

#Eliminamos un proceso de java corriendo en caso de que exista uno
execute 'kill existing spring boot app' do
  command "pkill -f 'java -jar' || true"
  only_if "pgrep -f 'java -jar'"
end

# Corremos la aplicacion de java
execute 'run spring boot app' do
  cwd APP_SUBDIR
  command "nohup java -jar target/*.jar"
end