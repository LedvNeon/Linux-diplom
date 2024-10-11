Vagrant.configure("2") do |config| #создаём конфигурацию для всех VM, используя сокращение config
  config.vm.box = "centos/9" #образ для всех vm
  config.vm.provision "shell", inline: <<-SHELL # через shell будут передаваться срипты
  mkdir -p ~root/.ssh # создаём директорию во всех VM
        cp ~vagrant/.ssh/auth* ~root/.ssh # копируем файл с ключами для подключения по ssh
  SHELL

  config.vm.define "webdmz" do |webdmz|
    $net=<<-NET
    route add default gw 10.200.1.1
    ifconfig eth0 down
    NET

    webdmz.vm.provider :virtualbox # укажем поставщика виртуализации
    webdmz.vm.hostname = "webdmz" # укажем имя VM (конкретно для данной VM)
    webdmz.vm.network "private_network", ip: "10.200.1.3", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    #пропишем открытый ключ для подключения ansibledmz по ssh (ansible)
    #webdmz.vm.provision "shell", inline: "echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxi53iEQA+ZL1O7Xx7uipmu6ee7N4xwF/tc1+yWfrZybXKYst+9STXyZ4j4D6SdZPQFB0Pp5dv1Nq3aaIQ7vTQKsuy/Fx/UNqwddlFB8ymtF+lUR8w+mNNoTCRMoFqPRrNR2TQKZm7ZPKws88oe9nexwBh5kmUmsLxXS8RDRsDL9oDkNO3xmcjLVu3mG7ko0hBr+y6J9TJNsYh/ZYDWXoIphBeDg4+BywxOSWRw3SKYAM8p2m0n+IOfj36ahHZjkPYFGm71Qrfg0h2cL8XYCoofzOmECv062BGvDhcGVVdhBRYLORIJfx4vxXt5QC5IosxG044IHaVMehXiXvWRYDonmwGduU9SowfhfCwnCDFw3tf1nzh8EIl0kc7WCLYYm+W2Nl5pFzbNyXzz2fGpzfKtTOke8ppB0PukEmNKm31F4hqnFB/QywWU6Bg6csOPZv+avi5OzPWlgkxtFDW7hnMWUy7WxR7oHiCmPpRe3lDx55Y2TqRVU/YSQbGK6/v2LM= vagrant@ansibledmz >> /home/vagrant/.ssh/authorized_keys"
    webdmz.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf"
    webdmz.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf"
    #webdmz.vm.provision "shell", inline: $net # выполним скрипт по наcтройке шлюза поумолчанию
    #webdmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
  end


  config.vm.define "ansibledmz" do |ansibledmz|
    ansibledmz.vm.provider :virtualbox # укажем поставщика виртуализации
    ansibledmz.vm.hostname = "ansibledmz" # укажем имя VM (конкретно для данной VM)
    ansibledmz.vm.network "private_network", ip: "10.200.1.2", virtualbox__intnet: "dmz_net" # укажем тип подсети и зададим ip (конкретно для данной VM)
    ansibledmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет (конкретно эта vm)
    #ansibledmz.vm.provision "file", source: "id_rsa_ansibledmz", destination: "/home/vagrant/.ssh/id_rsa"
    #ansibledmz.vm.provision "file", source: "id_rsa_pub_ansibledmz", destination: "/home/vagrant/.ssh/id_rsa.pub"
    ansibledmz.vm.provision "file", source: ".vagrant/machines/webdmz/virtualbox/private_key", destination: "/home/vagrant/.ssh/id_rsa_webdmz.pem"
    ansibledmz.vm.provision "shell", inline: "chmod 600 /home/vagrant/.ssh/id_rsa_webdmz.pem"
    ansibledmz.vm.provision "shell", inline: "echo nameserver 8.8.8.8 >> /etc/resolv.conf"
    ansibledmz.vm.provision "shell", inline: "echo nameserver 8.8.4.4 >> /etc/resolv.conf"
    ansibledmz.vm.provision "shell", path: "ansible.sh" # запустим скрипт с локально ОС
    ansibledmz.vm.provision "file", source: "web-server-dmz.yml", destination: "/etc/ansible/playbooks/web-server-dmz.yml"
    ansibledmz.vm.provision "shell", inline: "chmod 777 /etc/ansible/playbooks/web-server-dmz.yml"
    ansibledmz.vm.provision "shell", inline: "ansible-playbook /etc/ansible/playbooks/web-server-dmz.yml -f 10 --key-file /home/vagrant/.ssh/id_rsa_webdmz.pem"
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
