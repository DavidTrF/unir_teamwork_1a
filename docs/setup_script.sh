sudo apt update && sudo apt upgrade -y

wget https://packages.chef.io/files/stable/chef-workstation/24.12.1073/ubuntu/20.04/chef-workstation_24.12.1073-1_amd64.deb

sudo dpkg -i chef-workstation_24.12.1073-1_amd64.deb

chef --version

which chef
ls /opt/chef-workstation/bin/

chef generate repo chef-repo
cd chef-repo
