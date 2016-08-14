Infrastructure
==============

This is a ansible repository to deploy the system mes-aides


Test locally
------------

1. Install [Vagrant](https://www.vagrantup.com).
2. Run `vagrant up`.
3. There is no step 3.

To run your updated Ansible playbook, run `vagrant provision`.


Deploy on production
--------------------

 * Install python `ansible --sudo -i inventories/local -m raw -a "apt-get update && apt-get -y upgrade && apt-get install -y python" mes-aides`
 * Run ansible `ansible-playbook -i prod site.yml`
