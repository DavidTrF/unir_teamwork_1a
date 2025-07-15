# Ejercicio de Automatización con Chef: Instalación de Ngrok en macOS (M4)


Este proyecto forma parte de la asignatura de Automatización y tiene como objetivo demostrar la automatización de la instalación, configuración y prueba de la herramienta ngrok utilizando Chef en un entorno macOS con chip Apple M4.
 

Herramientas utilizadas
•    Chef Workstation 18.7.10
•    InSpec (para pruebas automatizadas)
•    macOS 15.5 en arquitectura ARM64 (chip Apple M4)
•    Ngrok (binario ARM64)
•    Git (control de versiones)
 

📂 Estructura de carpetas
•    Cookbook de Chef:
    /Users/shiningcode/chef/repo/cookbooks/chef_ngrok_demo
•    Proyecto de clase:
    /Users/shiningcode/unir_teamwork_1a
 

📆 Pasos realizados
1. Crear el cookbook con Chef
cd /Users/shiningcode/chef/repo/cookbooks
chef generate cookbook chef_ngrok_demo


2. Editar la receta default.rb
Se automatiza:
•    Descarga del binario ARM64 de ngrok
•    Creación del archivo de configuración ngrok.yml
•    Generación del script para lanzar el túnel


3. Ejecutar la receta con chef-client
cd /Users/shiningcode/chef/repo
sudo chef-client --local-mode --runlist 'recipe[chef_ngrok_demo]' \
  --config-option cookbook_path=/Users/shiningcode/chef/repo/cookbooks


4. Lanzar servidor local y script de ngrok
cd ~
python3 -m http.server 3000
./ngrok/lanzar_ngrok.sh
5. Verificar salida del túnel
cat ~/ngrok/ngrok.log
 

🔮 Pruebas automatizadas (InSpec)
Archivo: test/integration/default/default_test.rb
describe file("#{ENV['HOME']}/ngrok/ngrok") do
  it { should exist }
  it { should be_executable }
end

describe file("#{ENV['HOME']}/.ngrok2/ngrok.yml") do
  it { should exist }
  its('content') { should match /authtoken: dummy_token_para_clase/ }
end

describe file("#{ENV['HOME']}/ngrok/lanzar_ngrok.sh") do
  it { should exist }
  it { should be_executable }
end

describe port(4040) do
  it { should_not be_listening }
end


Ejecución:
chef exec inspec exec test/integration/default
 

📄 Resultado esperado
•    ngrok instalado en ~/ngrok/
•    Archivo ngrok.yml con token y región configurados
•    Script de lanzamiento funcionando
•    Salida en ngrok.log
•    Pruebas automatizadas exitosas
 
📚 Autor
Nombre: Yaressy
Grupo: 1040
Equipo: 1A
Institución: UNIR (Trabajo en equipo 1A)
