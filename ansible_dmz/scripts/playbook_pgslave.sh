#!/bin/bash
/usr/bin/ansible-playbook /etc/ansible/playbooks/pgslave.yml -f 10 --key-file /home/vagrant/.ssh/pgslave.pem