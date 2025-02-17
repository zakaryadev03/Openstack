#! /bin/bash
sudo apt install -y cephadm

cephadm bootstrap --mon-ip=10.0.0.12 \
  --cluster-network 10.0.0.0/24 \
  --initial-dashboard-password=admin \
  --dashboard-password-noupdate

cephadm add-repo --release squid

sudo apt-get install ceph-common

for node in ceph{2..3}
do
  echo "=== Copying ceph.pub to $node ==="
  ssh-copy-id -f -i /etc/ceph/ceph.pub root@$node
  echo ""
  sleep 2
done

for node in ceph{1..3}
do
  ceph orch host add $node
done

ceph orch apply osd --all-available-devices --method raw

for node in ceph{1..3}
do
  ceph orch host label add $node mon
  ceph orch host label add $node osd
done

for pool_name in volumes images backups vms
do
  ceph osd pool create $pool_name
  rbd pool init $pool_name
done

ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images' -o /etc/ceph/ceph.client.glance.keyring
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=images' -o /etc/ceph/ceph.client.cinder.keyring
ceph auth get-or-create client.nova mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=vms, allow rx pool=images' -o /etc/ceph/ceph.client.nova.keyring
ceph auth get-or-create client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups' -o /etc/ceph/ceph.client.cinder-backup.keyring


for node in controller compute{1..2}
do
  ssh root@$node sudo tee /etc/ceph/ceph.conf </etc/ceph/ceph.conf
done

