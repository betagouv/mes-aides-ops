Set up the [Mes Aides](https://mes-aides.gouv.fr) stack.

> Déploie l'infrastructure de Mes Aides.


In all cases
------------

1. Install [Ansible](http://www.ansible.com).


Test locally
------------

 * Run vagrant `vagrant up`
 * Install python `ansible --sudo -i inventories/local -m raw -a "apt-get update && apt-get -y upgrade && apt-get install -y python" mes-aides`
 * Run ansible `ansible-playbook -i inventories/local site.yml`



Deploy on production
--------------------

 * Install python `ansible --sudo -i inventories/local -m raw -a "apt-get update && apt-get -y upgrade && apt-get install -y python" mes-aides`
 * Run ansible `ansible-playbook -i prod site.yml`
