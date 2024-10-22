Vagrant.configure("2") do |config| #создаём конфигурацию для всех VM, используя сокращение config
  config.vm.box = "centos/9" #образ для всех vm
  config.vm.provision "shell", inline: <<-SHELL # через shell будут передаваться срипты
  mkdir -p ~root/.ssh # создаём директорию во всех VM
        cp ~vagrant/.ssh/auth* ~root/.ssh # копируем файл с ключами для подключения по ssh
  SHELL

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
    webdmz2.vm.provision "file", source: "web_dmz/files/rootCA.key", destination: "/etc/nginx/sites/rootCA.key"
    webdmz2.vm.provision "file", source: "web_dmz/files/rootCA.pem", destination: "/etc/nginx/sites/rootCA.pem"
    webdmz2.vm.provision "file", source: "web_dmz/files/rootCA.srl", destination: "/etc/nginx/sites/rootCA.srl"
    webdmz2.vm.provision "file", source: "web_dmz/files/org.csr", destination: "/etc/nginx/sites/org.csr"
    webdmz2.vm.provision "file", source: "web_dmz/files/org.crt", destination: "/etc/nginx/sites/org.crt"
    webdmz2.vm.provision "shell", inline: "chmod 777 /etc/nginx/sites/*"
    #webdmz2.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
  end


  config.vm.define "ansibledmz" do |ansibledmz|
    ansibledmz.vm.provider :virtualbox # укажем поставщика виртуализации
    ansibledmz.vm.hostname = "ansibledmz" # укажем имя VM (конкретно для данной VM)
    ansibledmz.vm.network "private_network", ip: "10.200.1.2", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    ansibledmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
    ansibledmz.vm.provision "file", source: ".vagrant/machines/webdmz2/virtualbox/private_key", destination: "/home/vagrant/.ssh/id_rsa_webdmz.pem" # копируем закрытый ключ ssh
    ansibledmz.vm.provision "shell", inline: "chmod 600 /home/vagrant/.ssh/id_rsa_webdmz.pem" # добавим права для ключа
    ansibledmz.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf" # пропишем dns
    ansibledmz.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf" # пропишем dns
    ansibledmz.vm.provision "shell", path: "ansible_dmz/scripts/ansible.sh" # запустим скрипт с локально ОС
    ansibledmz.vm.provision "file", source: "ansible_dmz/configs/web-server-dmz.yml", destination: "/etc/ansible/playbooks/web-server-dmz.yml" # копируем playbook для натсройки wbdmz
    ansibledmz.vm.provision "shell", inline: "chmod 777 /etc/ansible/playbooks/web-server-dmz.yml" # назначим права на playbook
    ansibledmz.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/etc_nginx_nginx.conf.txt", destination: "/etc/ansible/files/etc_nginx_nginx.conf"
    ansibledmz.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/etc_nginx_sites_example.conf.txt", destination: "/etc/ansible/files/etc_nginx_sites_example.conf"
    ansibledmz.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/etc_php-fpm.d_www.conf.txt", destination: "/etc/ansible/files/etc_php-fpm.d_www.conf"
    ansibledmz.vm.provision "file", source: "ansible_dmz/files_for_ansible_dmz/var_www_html_index.html.txt", destination: "/etc/ansible/files/var_www_html_index.html"
    ansibledmz.vm.provision "shell", inline: "chmod 777 /etc/ansible/files/*"
    # выполним playbook игнорируя тег network_webdmz
    #ansibledmz.vm.provision "shell", inline: "ansible-playbook /etc/ansible/playbooks/web-server-dmz.yml -f 10 --key-file /home/vagrant/.ssh/id_rsa_webdmz.pem --skip-tags 'install_docker_webdmz_play,network_webdmz'"
  end

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
	router.vm.provision "shell", inline: $script #выполним скрипт
  end

end
