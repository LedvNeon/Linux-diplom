#!/bin/bash
sudo /usr/bin/ansible-playbook -vvv /etc/ansible/playbooks/monitoring.yml -f 10 --key-file /home/vagrant/.ssh/monitoring.pem