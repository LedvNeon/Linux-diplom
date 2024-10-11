Vagrant.configure("2") do |config| #создаём конфигурацию для всех VM, используя сокращение config
  config.vm.box = "centos/9" #образ для всех vm
  config.vm.provision "shell", inline: <<-SHELL # через shell будут передаваться срипты
  mkdir -p ~root/.ssh # создаём директорию во всех VM
        cp ~vagrant/.ssh/auth* ~root/.ssh # копируем файл с ключами для подключения по ssh
  SHELL

  config.vm.define "webdmz" do |webdmz|
    webdmz.vm.provider :virtualbox # укажем поставщика виртуализации
    webdmz.vm.hostname = "webdmz" # укажем имя VM (конкретно для данной VM)
    webdmz.vm.network "private_network", ip: "10.200.1.3", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    webdmz.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf" # пропишем dns
    webdmz.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf" # пропишем dns
    webdmz.vm.provision "shell", inline: "yum -y update" # обнвоим ОС
    webdmz.vm.provision "shell", inline: "yum -y install epel-release" # установим репозиторий epel
    webdmz.vm.provision "shell", inline: "yum -y install traceroute tcpdump net-tools" # установка нужных утилит
    #webdmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
  end


  config.vm.define "ansibledmz" do |ansibledmz|
    ansibledmz.vm.provider :virtualbox # укажем поставщика виртуализации
    ansibledmz.vm.hostname = "ansibledmz" # укажем имя VM (конкретно для данной VM)
    ansibledmz.vm.network "private_network", ip: "10.200.1.2", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    ansibledmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
    ansibledmz.vm.provision "file", source: ".vagrant/machines/webdmz/virtualbox/private_key", destination: "/home/vagrant/.ssh/id_rsa_webdmz.pem" # копируем закрытый ключ ssh
    ansibledmz.vm.provision "shell", inline: "chmod 600 /home/vagrant/.ssh/id_rsa_webdmz.pem" # добавим права для ключа
    ansibledmz.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf" # пропишем dns
    ansibledmz.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf" # пропишем dns
    ansibledmz.vm.provision "shell", path: "ansible.sh" # запустим скрипт с локально ОС
    ansibledmz.vm.provision "file", source: "web-server-dmz.yml", destination: "/etc/ansible/playbooks/web-server-dmz.yml" # копируем playbook для натсройки wbdmz
    ansibledmz.vm.provision "shell", inline: "chmod 777 /etc/ansible/playbooks/web-server-dmz.yml" # назначим права на playbook
    # выполним playbook игнорируя тег network_webdmz
    ansibledmz.vm.provision "shell", inline: "ansible-playbook /etc/ansible/playbooks/web-server-dmz.yml -f 10 --key-file /home/vagrant/.ssh/id_rsa_webdmz.pem --skip-tags 'network_webdmz'"
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
    router.vm.provision "shell", path: "router.sh" # запустим скрипт с локально ОС
    router.vm.provision "file", source: "dmz_router_frr.conf", destination: "/etc/frr/frr.conf" #проброс файла конфига для OSPF с локальной ОС
	router.vm.provision "shell", inline: $script #выполним скрипт
  end

end
