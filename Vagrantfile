Vagrant.require_version ">= 1.7.0"  # for Ansible provisioner

ENV['LC_ALL'] = 'en_US.UTF-8'  # Vagrant passes host locale to guest, but guest machine does not have locale installed. Avoid complaints about it.

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.network 'private_network', ip: '192.168.56.134'

  config.vm.define 'mes_aides'

  config.vm.provider 'virtualbox' do |vbox|
    vbox.linked_clone = true if Vagrant::VERSION =~ /^1.8/  # do not duplicate the base image
  end

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = './site.yml'
    ansible.inventory_path = './inventories/local'
    ansible.sudo = true
    ansible.verbose ='v'
  end

end
