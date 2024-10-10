#!/bin/bash
yum update -y
yum install -y epel-release
yum install -y traceroute tcpdump net-tools
yum install -y https://rpm.frrouting.org/repo/frr-stable-repo-1-0.el8.noarch.rpm
yum install -y frr frr-pythontools
sysctl net.ipv4.conf.all.forwarding=1
echo zebra=yes >> /etc/frr/daemons
sed -i -e 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
