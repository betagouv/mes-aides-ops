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


Monitoring
----------

A `monitor` user is set up in production. It has a login shell that is the `monitor.sh` script. You can thus `ssh monitor@mes-aides.gouv.fr` to get vital signs of the app.

This user also runs `monitor-server.js` through `nohup` on the `8888` port, thus exposing the monitor over HTTP. The global NGINX service is set up to expose this port on `monitor.mes-aides.gouv.fr`.

Two different scanning services are used, in order to remove dependency on one specific provider to notify in case of a service failure.
This endpoint is scanned by [UptimeRobot](https://uptimerobot.com) on a 5-minutes interval, and will notify the team through Slack and SMS. It is also scanned on a 2-minutes interval by [SetCronJob](https://www.setcronjob.com) which will notify the team by email. The SetCronJob instance has to be manually rearmed (i.e. re-enabled after it gets automatically disabled on failure) when it has been triggered.
