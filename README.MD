Set up the [Mes Aides](https://mes-aides.gouv.fr) stack.

> Déploie l'infrastructure de Mes Aides.


In all cases
------------

1. Install [Ansible](http://www.ansible.com).
2. Get dependencies: `ansible-galaxy install -r requirements.yml`.


Test locally
------------

1. Install [Vagrant](https://www.vagrantup.com).
2. Run `vagrant up`.
3. There is no step 3.

To run your updated Ansible playbook, run `vagrant provision`.

> For faster runs, if you iterate often, run: `ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory site.yml` ([source](http://docs.ansible.com/ansible/guide_vagrant.html#running-ansible-manually)).


Deploy on production
--------------------

 * Install python `ansible --sudo -i inventories/prod -m raw -a "apt-get update && apt-get -y upgrade && apt-get install -y python" mes-aides`
 * Run ansible `ansible-playbook -i inventories/prod site.yml`
