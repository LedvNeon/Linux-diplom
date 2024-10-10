#!/bin/bash
sudo yum update -y #обновим ОС
sudo yum -y install epel-release #добавим репозиторий epel-release
sudo yum -y install ansible #установим ansible
#создадим inventory-файл
cat <<EOF> /etc/ansible/hosts
[web]
10.200.1.3
EOF
#обавим шлюз по-умолчанию
route add default gw 10.200.1.1
#выключим лишние интерфейсы
ifconfig eth0 down
ifconfig eth2 down