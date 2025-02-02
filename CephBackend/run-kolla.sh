#! /bin/sh
pip install 'ansible-core>=2.16,<2.17.99'
pip install git+https://opendev.org/openstack/kolla-ansible@master

sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

cp share/kolla-ansible/ansible/inventory/all-in-one .
cp -r share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /home/vagrant/kolla/globals.yml /etc/kolla

mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type = qemu
cpu_mode = none
EOF
# vim /etc/kolla/globals.yml
# ifconfig
# ip a

kolla-ansible install-deps
kolla-genpwd
kolla-ansible bootstrap-servers -i ./all-in-one
kolla-ansible prechecks -i ./all-in-one
kolla-ansible deploy -i ./all-in-one
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
cp /home/vagrant/kolla/init-runonce share/kolla-ansible/init-runonce
kolla-ansible post-deploy -i all-in-one
. /etc/kolla/admin-openrc.sh
cd share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
