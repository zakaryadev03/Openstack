# -*- mode: ruby -*-
# vi: set ft=ruby :
servers = [
  {
    :hostname => "controller",
    :box => "ubuntu/jammy64",
    :ram => 6144,
    :cpu => 2,
    :disk => "20GB",
    :script => "sh /vagrant/setups/deployment_setup.sh"
  },
  {
    :hostname => "compute1",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/compute1.sh"
  },
  {
    :hostname => "compute2",
    :box => "ubuntu/jammy64",
    :ram => 1024,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/compute2.sh"
  },
  {
    :hostname => "ceph1",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 2,
    :disk => "20GB",
    :script => "sh /vagrant/setups/ceph_setup.sh"
  },
  {
    :hostname => "ceph2",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/ceph2_setup.sh"
  },
  {
    :hostname => "ceph3",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/ceph3_setup.sh"
  }
]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.disksize.size = machine[:disk]
      node.vm.hostname = machine[:hostname]
      
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram], "--cpus", machine[:cpu]]
        vb.customize ["modifyvm", :id, "--nic2", "hostonly", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter"]
        vb.customize ["modifyvm", :id, "--nic3", "natnetwork", "--nat-network3", "ProviderNetwork1", "--nicpromisc3", "allow-all"]

        # Add disk to the controller node
        if machine[:hostname] == "controller"
         file_to_disk = File.realpath( "." ) + "/block1cinder.vdi"
         vb.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', "20480"]
         vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
        end

        # Add disk to the ceph nodes
        if machine[:hostname].start_with?("ceph")
         disk_file = File.realpath( "." ) + "/block1#{machine[:hostname]}.vdi"
         vb.customize ['createhd', '--filename', disk_file, '--format', 'VDI', '--size', "40480"]
         vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', disk_file]
        end
      end
      node.vm.provision "shell", inline: machine[:script], privileged: true, run: "once"
    end
  end
end
