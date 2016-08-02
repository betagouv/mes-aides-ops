Infrastructure
==============

This is a ansible repository to deploy the system mes-aides


Test localy
-----------

 * Run vagrant `vagrant up`
 * Add this to `~/.ssh/config`
 * Run ansible `ansible-playbook -i inventories/local site.yml`


### Chiffrer un certificat à déployer

`openssl aes-256-cbc -a -in mon.cert -out mon.cert.enc`

utiliser le mot de passe qui est dans secrets/reverse_proxy.yml

`ansible-vault edit secrets/reverse_proxy.yml`


Deploy on production
--------------------

 * Install python `ansible --sudo -i inventories/local -m raw -a "apt-get update && apt-get -y upgrade && apt-get install -y python" mes-aides`
 * get the dépendencies `ansible-galaxy install -r requirements.yml`
 * Run ansible `ansible-playbook -i prod site.yml`
