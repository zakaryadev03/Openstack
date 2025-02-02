#! /bin/sh

sudo cp /vagrant/60-custom.yaml /etc/netplan/60-custom.yaml
sudo chmod 600 /etc/netplan/60-custom.yaml
sudo cp /vagrant/99-disable-network-config.cfg /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo netplan generate
sudo netplan apply
sudo cp /vagrant/hosts /etc/hosts
sudo cp /vagrant/grub /etc/default/grub

sudo update-grub

sudo apt update -y
sudo apt upgrade -y

sudo apt-get update -y

# Install necessary packages
sudo apt-get install -y ca-certificates curl

# Create the directory for Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list again to include the Docker repository
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

sudo apt install -y git python3-dev libffi-dev gcc libssl-dev pkg-config libdbus-glib-1-dev build-essential cmake libglib2.0-dev mariadb-server

sudo apt install -y python3-venv

mkdir openstack
cd openstack
python3 -m venv .
. bin/activate
pip install --upgrade pip
pip install setuptools docker dbus-python

sudo pvcreate /dev/sdc
sudo vgcreate cinder-volumes /dev/sdc

echo "configfs" >> /etc/modules
update-initramfs -u
sudo systemctl daemon-reload

mkdir -p /home/vagrant/kolla
cp /vagrant/globals.yml /home/vagrant/kolla
cp /vagrant/run-kolla.sh /home/vagrant/kolla
cp /vagrant/init-runonce /home/vagrant/kolla

reboot
