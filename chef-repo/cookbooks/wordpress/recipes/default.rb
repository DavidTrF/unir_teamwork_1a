# Instalar Apache
package 'apache2' do
  action :install
end

service 'apache2' do
  action [:enable, :start]
end

# Instalar PHP y extensiones necesarias
%w(php libapache2-mod-php php-mysql).each do |pkg|
  package pkg do
    action :install
  end
end

# Instalar MySQL Server
package 'mysql-server' do
  action :install
end

service 'mysql' do
  action [:enable, :start]
end

# Crear base de datos y usuario para WordPress
execute 'create-wordpress-user-and-db' do
  command <<-EOH
    mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    mysql -e "CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';"
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
  EOH
  not_if "mysql -e \"SHOW DATABASES LIKE 'wordpress';\" | grep wordpress"
end

# Descargar WordPress
remote_file '/tmp/wordpress.tar.gz' do
  source 'https://wordpress.org/latest.tar.gz'
  action :create
end

# Extraer y mover WordPress
bash 'extract_wordpress' do
  cwd '/tmp'
  code <<-EOH
    tar -xzf wordpress.tar.gz
    cp -r wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html/
    chmod -R 755 /var/www/html/
    rm /var/www/html/index.html
  EOH
  not_if { ::File.exist?('/var/www/html/wp-config.php') }
end