#!/bin/bash
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=dmz --change-interface=eth1 --permanent
firewall-cmd --zone=dmz --add-port=443/tcp --permanent
firewall-cmd --zone=dmz --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=8081/tcp --permanent
firewall-cmd --zone=public --add-port=2443/tcp --permanent
firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=8081 protocol=tcp to-port=8080 to-addr=10.200.1.4'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2443 protocol=tcp to-port=443 to-addr=10.200.1.4'
firewall-cmd --permanent --zone=dmz --add-rich-rule='rule family=ipv4 source address=0.0.0.0/0 forward-port port=443 protocol=tcp to-port=443 to-addr=10.200.1.4'
firewall-cmd --permanent --zone=dmz --add-rich-rule='rule family=ipv4 source address=0.0.0.0/0 forward-port port=8080 protocol=tcp to-port=8080 to-addr=10.200.1.4'
firewall-cmd --permanent --zone=dmz --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2443 protocol=tcp to-port=443 to-addr=10.200.1.4'
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth1 -o eth3 -j ACCEPT
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth3 -o eth1 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i eth3 -o eth1 -p tcp --dport 443 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
firewall-cmd --new-policy=public-dmz --permanent
firewall-cmd --policy=public-dmz --add-ingress-zone=public --permanent
firewall-cmd --policy=public-dmz --add-egress-zone=dmz --permanent
firewall-cmd --policy=public-dmz --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=2443 protocol=tcp to-port=443 to-addr=10.200.1.4'
firewall-cmd --policy=public-dmz --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.0/24 forward-port port=8081 protocol=tcp to-port=8080 to-addr=10.200.1.4'
service firewalld restart