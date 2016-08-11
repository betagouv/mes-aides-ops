
ssh_pubkey = File.read(File.join(Dir.home, '.ssh', 'id_rsa.pub')).chomp

Vagrant.require_version ">= 1.7.0"

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.network 'private_network', ip: '192.168.56.134'
  config.vm.provider 'virtualbox' do |vbox|
    vbox.name = 'mes_aides'
  end

  config.vm.provision 'shell', inline: <<-SHELL
    sudo mkdir -p /home/ubuntu/.ssh -m 700  # not sure sudo is needed
    sudo echo '#{ssh_pubkey}' >> /home/ubuntu/.ssh/authorized_keys
    apt-get update
    apt-get -y upgrade
    apt-get install -y python
  SHELL

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = './site.yml'
    ansible.inventory_path = './inventories/local'
    ansible.sudo = true
    ansible.verbose ='v'
  end

end
