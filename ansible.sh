#!/bin/bash
sudo yum update -y
sudo yum -y install epel-release
sudo yum -y install ansible
cat <<EOF> /etc/ansible/hosts
[web]
10.200.1.3
EOF
