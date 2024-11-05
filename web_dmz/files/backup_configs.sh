#!/bin/bash
rm -rf /home/vagrant/backups/configs/*
cp /etc/nginx/nginx.conf /home/vagrant/backups/configs/nginx.conf.backup_$(date "+%Y-%m-%d-%H-%M-%S").txt
cp /etc/php-fpm.d/www.conf /home/vagrant/backups/configs/www.conf.backup_$(date "+%Y-%m-%d-%H-%M-%S").txt
cp /var/lib/pgsql/data/pg_hba.conf /home/vagrant/backups/configs/pg_hba.conf.backup_$(date "+%Y-%m-%d-%H-%M-%S").txt
cp /etc/nginx/sites/example.conf /home/vagrant/backups/configs/example.conf.backup_$(date "+%Y-%m-%d-%H-%M-%S").txt
cp /etc/nginx/sites/status.conf /home/vagrant/backups/configs/status.conf.backup_$(date "+%Y-%m-%d-%H-%M-%S").txt
chmod 777 /home/vagrant/backups/configs/*