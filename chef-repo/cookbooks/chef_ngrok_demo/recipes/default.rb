ngrok_dir = "#{ENV['HOME']}/ngrok"
ngrok_bin = "#{ngrok_dir}/ngrok"
ngrok_zip = "#{ngrok_dir}/ngrok.zip"
ngrok_config = "#{ENV['HOME']}/.ngrok2/ngrok.yml"
ngrok_script = "#{ngrok_dir}/lanzar_ngrok.sh"
ngrok_log = "#{ngrok_dir}/ngrok.log"

# Crear carpeta para ngrok
directory ngrok_dir do
  owner ENV['USER']
  recursive true
end

# Descargar ngrok ARM64
remote_file ngrok_zip do
  source 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip'
  action :create
end

# Descomprimir binario
execute 'descomprimir_ngrok' do
  command "unzip -o #{ngrok_zip} -d #{ngrok_dir}"
  not_if { ::File.exist?(ngrok_bin) }
end

# Dar permisos al binario
file ngrok_bin do
  mode '0755'
end

# Crear config dir si no existe
directory File.dirname(ngrok_config) do
  owner ENV['USER']
  recursive true
end

# Crear archivo ngrok.yml
file ngrok_config do
  content <<-YAML
authtoken: dummy_token_para_clase
region: us
YAML
  mode '0600'
  owner ENV['USER']
end

# Script para lanzar túnel ngrok
file ngrok_script do
  content <<-EOS
#!/bin/bash
#{ngrok_bin} http 3000 > #{ngrok_log} 2>&1 &
echo "ngrok iniciado en el puerto 3000"
EOS
  mode '0755'
  owner ENV['USER']
end
