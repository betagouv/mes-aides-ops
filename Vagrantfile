# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
  mes_aides:
    { ip: '192.168.56.134',
      name: 'mes_aides'
    }
}

ssh_pubkey = File.read(File.join(Dir.home, '.ssh', 'id_rsa.pub')).chomp

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'ubuntu/xenial64'
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provision 'shell', inline: <<-SHELL
    sudo mkdir -p /home/ubuntu/.ssh -m 700  # not sure sudo is needed
    sudo echo '#{ssh_pubkey}' >> /home/ubuntu/.ssh/authorized_keys
    apt-get update
    apt-get -y upgrade
    apt-get install -y python
  SHELL

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.


  config.vm.provider 'virtualbox' do |box|
    box.cpus = 1
    box.gui = false
  end

  vms.each_pair do |key, vm|
    config.vm.define key do |configvm|
      configvm.vm.network 'private_network', ip: vm[:ip]
      configvm.vm.provider 'virtualbox' do |box|
        box.memory = vm[:memory] || '512'
        box.name = vm[:name]
      end
    end
  end
end
