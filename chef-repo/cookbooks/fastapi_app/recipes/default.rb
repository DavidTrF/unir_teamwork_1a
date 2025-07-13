#
# Cookbook:: fastapi_app
# Recipe:: default
#

# Actualización del sistema (opcional pero recomendado)
execute 'apt_update' do
  command 'apt update && apt upgrade -y'
end

# Instalación de herramientas necesarias
package %w(python3-venv curl) do
  action :install
end

# Crear directorio para la aplicación
directory '/home/ubuntu-unir/fastapi_app' do
  owner 'ubuntu-unir'
  group 'ubuntu-unir'
  mode '0755'
  recursive true
  action :create
end

# Crear entorno virtual solo si no existe
execute 'crear entorno virtual' do
  command 'python3 -m venv .venv'
  cwd '/home/ubuntu-unir/fastapi_app'
  user 'ubuntu-unir'
  environment({ 'HOME' => '/home/ubuntu-unir' })
  not_if { ::File.exist?('/home/ubuntu-unir/fastapi_app/.venv/bin/activate') }
end

# Instalar FastAPI en el entorno virtual
execute 'instalar fastapi' do
  command '/home/ubuntu-unir/fastapi_app/.venv/bin/pip install "fastapi[standard]"'
  cwd '/home/ubuntu-unir/fastapi_app'
  user 'ubuntu-unir'
  environment({
    'HOME' => '/home/ubuntu-unir',
    'PATH' => '/home/ubuntu-unir/fastapi_app/.venv/bin:/usr/bin:/bin'
  })
end

# Crear el archivo main.py desde plantilla
template '/home/ubuntu-unir/fastapi_app/main.py' do
  source 'main.py.erb'
  owner 'ubuntu-unir'
  group 'ubuntu-unir'
  mode '0644'
end

# Crear script de arranque (opcional, no se usa si se define systemd)
file '/home/ubuntu-unir/fastapi_app/start.sh' do
  content <<~BASH
    #!/bin/bash
    cd /home/ubuntu-unir/fastapi_app
    source .venv/bin/activate
    fastapi run main.py --host 0.0.0.0 --port 80
  BASH
  owner 'ubuntu-unir'
  group 'ubuntu-unir'
  mode '0755'
end

# Crear servicio systemd para ejecutar FastAPI
file '/etc/systemd/system/fastapi.service' do
  content <<~UNIT
    [Unit]
    Description=FastAPI Application
    After=network.target

    [Service]
    User=ubuntu-unir
    WorkingDirectory=/home/ubuntu-unir/fastapi_app
    ExecStart=/home/ubuntu-unir/fastapi_app/.venv/bin/python -m fastapi run main.py --host 0.0.0.0 --port 80
    Restart=always

    [Install]
    WantedBy=multi-user.target
  UNIT
  mode '0644'
end

# Recargar y activar el servicio systemd
execute 'reload systemd' do
  command 'systemctl daemon-reexec && systemctl daemon-reload'
end

service 'fastapi' do
  action [:enable, :start]
end