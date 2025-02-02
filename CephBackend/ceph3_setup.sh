#! /bin/sh

sudo cp /vagrant/90-custom.yaml /etc/netplan/60-custom.yaml
sudo chmod 600 /etc/netplan/90-custom.yaml
sudo cp /vagrant/99-disable-network-config.cfg /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo netplan generate
sudo netplan apply
sudo cp /vagrant/hosts /etc/hosts
sudo cp /vagrant/grub /etc/default/grub

sudo update-grub
sudo timedatectl set-timezone Africa/Casablanca

sudo apt update -y
sudo apt upgrade -y

reboot