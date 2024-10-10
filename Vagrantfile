Vagrant.configure("2") do |config|
  config.vm.box = "centos/9"
  config.vm.provision "shell", inline: <<-SHELL # через shell будут передаваться срипты
  mkdir -p ~root/.ssh # создаём директорию во всех VM
        cp ~vagrant/.ssh/auth* ~root/.ssh # копируем автоматически сгенерированный локальный файл с ключами ssh на все VM
  SHELL

  config.vm.define "ansibledmz" do |ansibledmz|
    ansibledmz.vm.provider :virtualbox # укажем поставщика виртуализации
    ansibledmz.vm.hostname = "ansible" # укажем имя VM (конкретно для данной VM)
    ansibledmz.vm.network "private_network", ip: "10.200.1.2", virtualbox__intnet: "dmz_net"
    # укажем тип подсети и зададим ip (конкретно для данной VM)
    ansibledmz.vm.network "public_network", ip: "192.168.0.5" # второй адаптер для временного доступа в интернет
    # для загрузки данных из публичных репозиториев - будет выключен в серипте
    ansibledmz.vm.provision "shell", path: "ansible.sh" # запустим скрипт с локально ОС
  end

end
