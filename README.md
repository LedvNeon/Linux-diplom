# Linux-diplom
В данном разделе описана моя дипломная работа по администрированию Linux.
Задача:
Создание рабочего проекта с развертыванием нескольких виртуальных машин по требованиям:

 - включен https;
 - основная инфраструктура в DMZ зоне;
 - файрвалл на входе;
 - настроен мониторинг и алертинг;
 - организован централизованный сбор логов;
 - организован backup.

1. Схема сети представлена на рис. "Схема моей сети"

2. Для корректного запуска нужно сделать следующее:
   - установить на ПК vagrant (в РФ ставится только через VPN)
   - склонировать мой git-репозиторий и переименовать vagrantfile (как удобно)
   - скачать box centos/9 - https://app.vagrantup.com/boxomatic/boxes/centos-stream-9/versions/20240419.0.1/providers/virtualbox/amd64/vagrant.box (прямая ссылка на загрузку)
   - переименовать скачанный файл, добавив расширение .box
   - перейти в каталог, куда склонирован git-репозиторий и выполнить следующие команды: 
     A) vagrant box add centos/9 "путь к скаченному файлу"
	 B) vagrant init centos/9
   - теперь в созданный vagrantfile нужно скопировать код из переименованного (НЕ ТРОГАЯ СТРОКУ config.vm.box с текущим образом)
   - так же в vagrantfile необходимо изменить адреса из публичной сети на свои (т.к. тут используются мои домашние).
     Т.е. присвоить интерфейсам из подсети 192.168.0.0/24 адреса из своей подсети
   - в файле dmz_router_frr.conf изменить разделы interface eth3 и router ospf, указав там свою домашнюю сеть и роутер
     (ip address 192.168.0.10/24 - изменить на свою, network 192.168.0.0/24 area 0  - изменить на свою,  neighbor 192.168.0.1 - указать свой роутер)
   - важно обратить внимание на строки в vagrantfile связанные с переносом закрытого ключа на vm
     "ansibledmz.vm.provision "file", source: ".vagrant/machines/webdmz/virtualbox/private_key", destination: "/home/vagrant/.ssh/id_rsa_webdmz.pem"" (пример)
	 расположение вашего ключа в хостовой ОС может отличаться - в этом случае в них так же необходимо внести изменения

3. Сделать "vagrant up"

4. РЕЗУЛЬТАТ
   Список развёрнутых серверов показан на рис. "Схема моей сети.png".
   
   ПОДКЛЮЧИТЬСЯ К НИМ ВОЗМОЖНО ПО SSH ЧЕРЕЗ "ssh vagrant@p-адрес-который-вы-задали-в-п-2 -p PORT -i "путь к закрытому ключу 
   у меня это "C:\git\linux-diplom\.vagrant\machines\имяVM\privat_key")" -o StrictHostKeyChecking=no (отключим строгу. проверку ключа хоста).
   
   Для каждого сервера свой порт:
   ansible - 2244
   webdmz2 - 2222
   monitoring - 2224
   В результате "vagrant up" web-сервер (динамический) по https будет доступен по адресу: https://ip-адрес-который-вы-задали-в-п-2:2443.
   Cодержимое: результат запроса в БД от php-скрипта.
   Web-сервер по http будет доступен по адресу: http://ip-адрес-который-вы-задали-в-п-2:8000 (статика)
   Web-сервер STATUS будет доступен по адресу: http://ip-адрес-который-вы-задали-в-п-2:8001/status
   Для проверки мониторинга необходимо открыть браузер по адресу http://ip-адрес-который-вы-задали-в-п-2:3000 - откроется grafana (admin-admin (логин и пароль)).
   В открывшуюся grafana нужно импортировать dashboard.json (лежит в репозитории в корне linux-diplom) и подождать 10 минут.
   Перед импортом dashboard.json, необходимо заменить в нём uid для datasorce на новый.
   UID можно найти, перейдя по адресу http://ip-адрес-который-вы-задали-в-п-2:3000/api/datasources
   Так же во время имопрта его нужно будет указать и в веб-интерфейсе.
   prometheus - http://ip-адрес-который-вы-задали-в-п-2:9090;
   node_exporter http://ip-адрес-который-вы-задали-в-п-2:9100;
   nginx_exporter http://ip-адрес-который-вы-задали-в-п-2:9113.
   Бекапы можно найти через 15 минут после старта на ansibledmz2 в папке /home/vagrant/backups.
   Централизованный сбор логов так же реализован на ansibledmz2 (папка /var/log/rsyslog/).
   База данных, с которой тянется контент для https://ip-адрес-который-вы-задали-в-п-2:2443 реплицируется (см. схему).
   Так же реализован алертинг в telegram в чат-бота (адрес не указываю - возможно, вы захотите настроить свой).

   