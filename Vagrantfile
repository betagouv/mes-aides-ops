Vagrant.require_version ">= 1.7.0"  # for Ansible provisioner

ENV['LC_ALL'] = 'en_US.UTF-8'  # Vagrant passes host locale to guest, but guest machine does not have locale installed. Avoid complaints about it.

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.network 'private_network', ip: '192.168.56.134'
  config.vm.provider 'virtualbox' do |vbox|
    vbox.name = 'mes_aides'
    vbox.linked_clone = true if Vagrant::VERSION =~ /^1.8/  # do not duplicate the base image
  end

  config.vm.provision 'shell', inline: <<-SHELL
    apt-get update
    apt-get -y upgrade
    apt-get install -y python  # xenial64 comes with Python3, Ansible needs Python2.7
  SHELL

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = './site.yml'
    ansible.inventory_path = './inventories/local'
    ansible.sudo = true
    ansible.verbose ='v'
  end

end
