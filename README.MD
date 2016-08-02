Infrastructure
==============

This is a ansible repository to deploy the system mes-aides


Test localy
-----------

 * Run vagrant `vagrant up`
 * Run `ansible-galaxy install -r requirements.yml` to install dependencies
 * Run ansible `ansible-playbook -i inventories/local site.yml`



Deploy on production
--------------------

 * Install python `ansible --sudo -i inventories/local -m raw -a "apt-get update && apt-get -y upgrade && apt-get install -y python" mes-aides`
 * get the dépendencies `ansible-galaxy install -r requirements.yml`
 * Run ansible `ansible-playbook -i prod site.yml`
