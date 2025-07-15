# InSpec test for recipe[chef_ngrok_demo::default]

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
  it { should_not be_listening } # Si quieres probar ngrok activo, lanza el túnel antes
end
