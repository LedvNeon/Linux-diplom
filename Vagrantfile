Vagrant.configure("2") do |config| #создаём конфигурацию для всех VM, используя сокращение config
  config.vm.box = "centos/9" #образ для всех vm
  config.vm.provision "shell", inline: <<-SHELL # через shell будут передаваться срипты
  mkdir -p ~root/.ssh # создаём директорию во всех VM
        cp ~vagrant/.ssh/auth* ~root/.ssh # копируем файл с ключами для подключения по ssh
  SHELL

  config.vm.define "router" do |router| # define - описание одной vm
    
    # создадим переменную, в рамках которой выполним скрипт bash
    $script=<<-SCRIPT
	chown frr:frr /etc/frr/frr.conf
    chmod 640 /etc/frr/frr.conf
    chown frr:frr /etc/frr/daemons
    chmod 640 /etc/frr/daemons
    systemctl restart frr
    systemctl enable frr
    SCRIPT

    router.vm.provider :virtualbox # укажем поставщика виртуализации
    router.vm.hostname = "router" # укажем имя VM (конкретно для данной VM)
    router.vm.network "private_network", ip: "10.200.1.1", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    router.vm.network "private_network", ip: "172.16.1.1", virtualbox__intnet: "servers_net"
    router.vm.network "public_network", ip: "192.168.0.10" # второй адаптер для доступа в интернет (через мою домашнюю сеть)
    router.vm.provision "shell", path: "router/scripts/router.sh" # запустим скрипт с локально ОС
    router.vm.provision "file", source: "router/files/dmz_router_frr.conf", destination: "/etc/frr/frr.conf" #проброс файла конфига для OSPF с локальной ОС
    router.vm.provision "shell", path: "router/scripts/firewalld.sh" #выполним скрипт настройки firewalld
    router.vm.provision "shell", inline: "systemctl restart frr" # рестарт frr
	router.vm.provision "shell", inline: $script #выполним скрипт
  end

  config.vm.define "webdmz2" do |webdmz2|
    webdmz2.vm.provider :virtualbox # укажем поставщика виртуализации
    webdmz2.vm.hostname = "webdmz2" # укажем имя VM (конкретно для данной VM)
    webdmz2.vm.network "private_network", ip: "10.200.1.4", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    webdmz2.vm.network "forwarded_port", guest: 8080, host: 8080
    webdmz2.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf" # пропишем dns
    webdmz2.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf" # пропишем dns
    webdmz2.vm.provision "shell", inline: "yum -y update" # обновим ОС
    webdmz2.vm.provision "shell", inline: "yum -y install epel-release" # установим репозиторий epel
    webdmz2.vm.provision "shell", inline: "yum -y install traceroute tcpdump net-tools nginx php php-fpm postgresql postgresql-server php-pgsql" # установка нужных утилит
    webdmz2.vm.provision "shell", inline: "postgresql-setup --initdb" # инициализация БД
    webdmz2.vm.provision "shell", inline: "systemctl start postgresql.service" # запуск БД
    webdmz2.vm.provision "shell", inline: "systemctl enable postgresql.service" # добавили БД в автозагрузку
    webdmz2.vm.provision "shell", path: "web_dmz/scripts/web_dmz.sh"
    webdmz2.vm.provision "file", source: "web_dmz/files/index.php", destination: "/var/www/html/index.php"
    webdmz2.vm.provision "shell", inline: "chmod 777 /var/www/html/index.php"
    webdmz2.vm.provision "file", source: "web_dmz/files/index.html.txt", destination: "/var/www/html/index.html"
    webdmz2.vm.provision "shell", inline: "chmod 777 /var/www/html/index.html"
    webdmz2.vm.provision "shell", inline: "chmod 777 /etc/systemd/system"
    webdmz2.vm.provision "shell", inline: "chmod 777 /etc/systemd"
    webdmz2.vm.provision "shell", inline: "chmod 777 /etc"
    webdmz2.vm.provision "file", source: "web_dmz/files/nginx-exporter.service", destination: "/etc/systemd/system/nginx-exporter.service"
    webdmz2.vm.provision "shell", inline: "chmod 777 /etc/systemd/system/nginx-exporter.service"
    webdmz2.vm.provision "file", source: "web_dmz/files/rootCA.key", destination: "/etc/nginx/sites/rootCA.key"
    webdmz2.vm.provision "file", source: "web_dmz/files/rootCA.pem", destination: "/etc/nginx/sites/rootCA.pem"
    webdmz2.vm.provision "file", source: "web_dmz/files/rootCA.srl", destination: "/etc/nginx/sites/rootCA.srl"
    webdmz2.vm.provision "file", source: "web_dmz/files/org.csr", destination: "/etc/nginx/sites/org.csr"
    webdmz2.vm.provision "file", source: "web_dmz/files/org.crt", destination: "/etc/nginx/sites/org.crt"
    webdmz2.vm.provision "file", source: "web_dmz/files/backupDB.sh", destination: "/home/vagrant/backupDB.sh"
    webdmz2.vm.provision "file", source: "web_dmz/files/backup_configs.sh", destination: "/home/vagrant/backup_configs.sh"
    webdmz2.vm.provision "shell", inline: "chmod 777 /home/vagrant/backupDB.sh && chmod 777 /home/vagrant/backup_configs.sh"
    webdmz2.vm.provision "shell", inline: "mkdir /home/vagrant/backups"
    webdmz2.vm.provision "shell", inline: "chmod 777 /home/vagrant/backups"
    webdmz2.vm.provision "shell", inline: "chmod 777 /etc/nginx/sites/* && chmod 777 /usr/bin/pg_dump"
    webdmz2.vm.provision "shell", inline: "sudo su && echo '*/10 * * * * /home/vagrant/backupDB.sh' >> /var/spool/cron/root"
    webdmz2.vm.provision "shell", inline: "sudo su && echo '*/15 * * * * /home/vagrant/backup_configs.sh' >> /var/spool/cron/root"
    #webdmz2.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
  end

  config.vm.define "monitoring" do |monitoring|
    monitoring.vm.provider :virtualbox
    monitoring.vm.hostname = "monitoring"
    monitoring.vm.network "private_network", ip: "172.16.1.5", virtualbox__intnet: "servers_net"
    monitoring.vm.provision "shell", inline: "route add default gw 172.16.1.1"
    monitoring.vm.provision "shell", inline: "yum update -y"
    #monitoring.vm.provision "shell", inline: "mkdir /vagrant/monitoring && chmod 777 /vagrant/monitoring && mkdir /vagrant/monitoring/configs && chmod 777 /vagrant/monitoring/configs && mkdir /vagrant/monitoring/configs/prometheus"
    monitoring.vm.provision "file", source: "monitoring/configs/docker-compose.yml", destination: "/vagrant/monitoring/configs/docker-compose.yml"
    monitoring.vm.provision "shell", inline: "chmod 777 /vagrant/monitoring/*"
    monitoring.vm.provision "shell", inline: "chmod 777 /vagrant/monitoring/configs/*"
    monitoring.vm.provision "file", source: "monitoring/configs/prometheus.yml", destination: "/vagrant/monitoring/configs/prometheus/prometheus.yml"
    monitoring.vm.provision "shell", inline: "mkdir /etc/prometheus"
    monitoring.vm.provision "shell", inline: "chmod 777 /etc/prometheus && chmod 777 /vagrant/monitoring/configs/prometheus"
    monitoring.vm.provision "shell", inline: "cp /vagrant/monitoring/configs/prometheus.yml /vagrant/monitoring/configs/prometheus/prometheus.yml"
    monitoring.vm.provision "shell", inline: "yum install -y pip"
    monitoring.vm.provision "shell", inline: "sudo ifconfig eth0 down"
  end

  config.vm.define "ansibledmz2" do |ansibledmz2|
    ansibledmz2.vm.provider :virtualbox # укажем поставщика виртуализации
    ansibledmz2.vm.hostname = "ansibledmz2" # укажем имя VM (конкретно для данной VM)
    ansibledmz2.vm.network "private_network", ip: "10.200.1.7", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    #ansibledmz2.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
    ansibledmz2.vm.provision "file", source: ".vagrant/machines/webdmz2/virtualbox/private_key", destination: "/home/vagrant/.ssh/id_rsa_webdmz.pem" # копируем закрытый ключ ssh
    ansibledmz2.vm.provision "file", source: ".vagrant/machines/monitoring/virtualbox/private_key", destination: "/home/vagrant/.ssh/monitoring.pem"
    ansibledmz2.vm.provision "shell", inline: "chmod 600 /home/vagrant/.ssh/*" # добавим права для ключа
    ansibledmz2.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf" # пропишем dns
    ansibledmz2.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf" # пропишем dns
    ansibledmz2.vm.provision "shell", path: "ansible_dmz/scripts/ansible.sh" # запустим скрипт с локально ОС
    ansibledmz2.vm.provision "file", source: "ansible_dmz/configs/web-server-dmz.yml", destination: "/etc/ansible/playbooks/web-server-dmz.yml" # копируем playbook для натсройки wbdmz
    ansibledmz2.vm.provision "file", source: "ansible_dmz/configs/monitoring.yml", destination: "/etc/ansible/playbooks/monitoring.yml"
    ansibledmz2.vm.provision "shell", inline: "chmod 777 /etc/ansible/playbooks/*" # назначим права на playbook
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/etc_nginx_nginx.conf.txt", destination: "/etc/ansible/files/etc_nginx_nginx.conf"
    #ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/hosts", destination: "/etc/ansible/hosts"
    #ansibledmz2.vm.provision "shell", inline: "chmod 777 /etc/ansible/hosts"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/status.conf.txt", destination: "/etc/ansible/files/status.conf"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/etc_nginx_sites_example.conf.txt", destination: "/etc/ansible/files/etc_nginx_sites_example.conf"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/etc_php-fpm.d_www.conf.txt", destination: "/etc/ansible/files/etc_php-fpm.d_www.conf"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/var_www_html_index.html.txt", destination: "/etc/ansible/files/var_www_html_index.html"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/pg_hba.conf.txt", destination: "/etc/ansible/files/pg_hba.conf"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/node_exporter.service.txt", destination: "/etc/ansible/files/node_exporter.service"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/nginx_exporter.service.txt", destination: "/etc/ansible/files/nginx_exporter.service"
    ansibledmz2.vm.provision "shell", inline: "chmod 777 /etc/ansible/files/*"
    ansibledmz2.vm.provision "shell", inline: "/usr/bin/ansible-galaxy collection install community.docker --upgrade"
    ansibledmz2.vm.provision "shell", inline: "mkdir /home/vagrant/backups/ && mkdir /home/vagrant/backups/db && mkdir /home/vagrant/backups/config"
    ansibledmz2.vm.provision "shell", inline: "chmod 777 /home/vagrant/backups && chmod 777 /home/vagrant/backups/*"
    ansibledmz2.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/backup.sh", destination: "/home/vagrant/backup.sh"
    ansibledmz2.vm.provision "shell", inline: "chmod 777 /home/vagrant/backup.sh"
    ansibledmz2.vm.provision "shell", inline: "sudo su && echo '*/17 * * * * /home/vagrant/backup.sh' >> /var/spool/cron/root"
    ansibledmz2.vm.provision "shell", inline: "sudo route add default gw 10.200.1.1"
    ansibledmz2.vm.provision "shell", inline: "sudo ifconfig eth0 down"
    # выполним playbook игнорируя тег network_webdmz
    ansibledmz2.vm.provision "shell", inline: "/usr/bin/ansible-playbook /etc/ansible/playbooks/web-server-dmz.yml -f 10 --key-file /home/vagrant/.ssh/id_rsa_webdmz.pem --skip-tags 'install_docker_monitoring_play, network_webdmz'"
    ansibledmz2.vm.provision "shell", inline: "sudo /usr/bin/ansible-playbook /etc/ansible/playbooks/monitoring.yml -f 10 --key-file /home/vagrant/.ssh/monitoring.pem"
    #ansibledmz2.vm.provision "shell", inline: "shutdown -h 0"
  end

end
