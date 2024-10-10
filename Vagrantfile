Vagrant.configure("2") do |config| #создаём конфигурацию для всех VM, используя сокращение config
  config.vm.box = "centos/9" #образ для всех vm
  config.vm.provision "shell", inline: <<-SHELL # через shell будут передаваться срипты
  mkdir -p ~root/.ssh # создаём директорию во всех VM
        cp ~vagrant/.ssh/auth* ~root/.ssh # копируем файл с ключами для подключения по ssh
  SHELL

  config.vm.define "ansibledmz" do |ansibledmz|
    ansibledmz.vm.provider :virtualbox # укажем поставщика виртуализации
    ansibledmz.vm.hostname = "ansibledmz" # укажем имя VM (конкретно для данной VM)
    ansibledmz.vm.network "private_network", ip: "10.200.1.2", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    ansibledmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
    ansibledmz.vm.provision "shell", path: "ansible.sh" # запустим скрипт с локально ОС
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
