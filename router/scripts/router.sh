#!/bin/bash
yum update -y #обновим ОС
yum install -y epel-release #добавим репозиторий epel-release
yum install -y traceroute tcpdump net-tools #установим traceroute, tcpdump и net-tools
yum install -y https://rpm.frrouting.org/repo/frr-stable-repo-1-0.el8.noarch.rpm #подключим репозиторий для загрузки frr (для OSPF)
yum install -y frr frr-pythontools --nobest #установим frr и frr-pythontools не выбираю лучшую сборку - работает только так
sysctl net.ipv4.conf.all.forwarding=1 # разрешим транзитный трафик
echo zebra=yes >> /etc/frr/daemons #добавим в файл /etc/frr/daemons запись zebra=yes - для корректной работы OSPF
sed -i -e 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons # изменим ospfd=no на yes - для корректной работы OSPF
rm -rf /etc/frr/frr.conf #удалим файл конфига для ospf
# пробросим новый /etc/frr/frr.conf через vagrant из локальной ОС
chmod 777 /etc # максимальные права для владельца/группы/пользователей (только для тестовой среды)
chmod 777 /etc/frr # максимальные права для владельца/группы/пользователей (только для тестовой среды)