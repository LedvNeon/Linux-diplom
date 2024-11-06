#!/bin/bash
/usr/bin/ansible-playbook /etc/ansible/playbooks/web-server-dmz.yml -f 10 --key-file /home/vagrant/.ssh/id_rsa_webdmz.pem --skip-tags "install_docker_monitoring_play, network_webdmz"