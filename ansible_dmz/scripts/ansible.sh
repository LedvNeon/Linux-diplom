#!/bin/bash
yum update -y #обновим ОС
yum -y install epel-release #добавим репозиторий epel-release
yum install -y python3
yum -y install ansible #установим ansible

#создадим inventory-файл
cat <<EOF> /etc/ansible/hosts
[web]
webdmz2 ansible_host=10.200.1.4
[web:vars}
ansible_user=vagrant
EOF

# изменим права (так делаем только в рамка хтестовой среды)
chmod 777 /etc
chmod 777 /etc/ansible
# создадим дирректорию для playbooks
sudo mkdir /etc/ansible/playbooks
chmod 777 /etc/ansible/playbooks

# Внесём изменения в конфиг для ansible, что бы playbook 
# не запрашивал подтверждения на доверия хосту при подключении
cat <<EOF> /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
EOF

#обавим шлюз по-умолчанию
route add default gw 10.200.1.1

mkdir /etc/ansible/files
chmod 777 /etc/ansible/files