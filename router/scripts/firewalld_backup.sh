#!/bin/bash
systemctl start firewalld # старт firewalld
systemctl enable firewalld # добавили в автозагрузу firewalld
firewall-cmd --zone=dmz --change-interface=eth1 --permanent # назначим интерфейс подсети 10.200.1.0/24 (eth1), как dmz
firewall-cmd --zone=dmz --add-port=443/tcp --permanent # откроем порт 443 на dmz для https
firewall-cmd --zone=dmz --add-port=8080/tcp --permanent # откроем порт 8080 на dmz для http
firewall-cmd --zone=dmz --add-port=22/tcp --permanent  # откроем порт 22 на public для ssh
firewall-cmd --zone=public --add-port=8000/tcp --permanent # откроем порт 8000 на public для http
firewall-cmd --zone=public --add-port=2443/tcp --permanent  # откроем порт 2443 на public для https
firewall-cmd --zone=public --add-port=2222/tcp --permanent  # откроем порт 2222 на public для ssh
#firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=8081 protocol=tcp to-port=8080 to-addr=10.200.1.4'
#firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2443 protocol=tcp to-port=443 to-addr=10.200.1.4'
#firewall-cmd --permanent --zone=dmz --add-rich-rule='rule family=ipv4 source address=0.0.0.0/0 forward-port port=443 protocol=tcp to-port=443 to-addr=10.200.1.4'
#firewall-cmd --permanent --zone=dmz --add-rich-rule='rule family=ipv4 source address=0.0.0.0/0 forward-port port=8080 protocol=tcp to-port=8080 to-addr=10.200.1.4'
#firewall-cmd --permanent --zone=dmz --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2443 protocol=tcp to-port=443 to-addr=10.200.1.4'
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth1 -o eth3 -j ACCEPT # разрешим трафик от интерфейса eth1 к eth3
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth3 -o eth1 -j ACCEPT # разрешим трафик от интерфейса eth3 к eth1
# firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i eth3 -o eth1 -p tcp --dport 443 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
#firewall-cmd --new-policy=public-dmz --permanent # создаём политику для интерфейсов public и dmz (по умолчанию трафик между ними заблокирован)
#firewall-cmd --policy=public-dmz --add-ingress-zone=public --permanent # (укажем зону отправитель - с которой будет поступать трафик)
#firewall-cmd --policy=public-dmz --add-egress-zone=dmz --permanent #(укажем зону получатель - куда будет поступать трафик с ingress)
# добавим в политику правило перенаправления трафика с 2443(https),2222(ssh),8000(http) public на 443, 22, 8080 соответственно в dmz
#firewall-cmd --policy=public-dmz --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2443 protocol=tcp to-port=443 to-addr=10.200.1.4'
#firewall-cmd --policy=public-dmz --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=8000 protocol=tcp to-port=8080 to-addr=10.200.1.4'
#firewall-cmd --policy=public-dmz --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2222 protocol=tcp to-port=22 to-addr=10.200.1.4'
firewall-cmd --zone=public --add-masquerade --permanent # включим NAT на public
firewall-cmd --zone=dmz --add-masquerade --permanent # включим NAT на dmz
# пробросим порты 8000, 2443, 2222 из зоны public на 10.200.1.4
firewall-cmd --zone=public --add-forward-port=port=8000:proto=tcp:toport=8080:toaddr=10.200.1.4 --permanent
firewall-cmd --zone=public --add-forward-port=port=2443:proto=tcp:toport=443:toaddr=10.200.1.4 --permanent
firewall-cmd --zone=public --add-forward-port=port=2222:proto=tcp:toport=22:toaddr=10.200.1.4 --permanent
service firewalld restart # рестарт firewalld