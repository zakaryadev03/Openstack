# Openstack
Repo about deploying multinodes openstack with an external ceph cluster as backend.

the scripts provided cover almost everything, the only thing remainging is modifying two kolla config files. (the reason to not automating the config the same as the other steps is due to ansible parser problem).

Steps to deploy:

`Vagrant up` to start the 6 Vms (Controller, compute{1..2} and ceph{1..3})

it will take sometime to complete the provision scripts in setup folder, those scripts just install the necessary tools for ansible and ceph and configure the network interfaces.
