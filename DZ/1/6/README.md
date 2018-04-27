#


## 1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

#

Написал скрипт diag.sh поместил его в /root/script/diag.sh. Написав в нем цикл с интервалом времени 30 с. Пример выполнения получился таким ' /root/script/diag.sh Fatal /var/log/messages /var/log/diag.log ' . Опции указал в конфиге diag который положил в '/etc/sysconfig/ ' . Юнит 'diag.service' к данному скрипту лежит в '/etc/systemd/system/'. Лог исполнения в директории 

Все файлы расположенны в директории (diag).

#

## 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться.

#

Для того чтобы установить 'spawn-fcgi' выполним:

```
yum install -y epel-release 
yum install -y spawn-fcgi 

```
После установки найдем интересующие нас файлы сервиса, а именно скрипт запуска, конфиг и сам бинарный файл сервиса.

```

find / | grep spawn-fcgi

```

```

/etc/rc.d/init.d/spawn-fcgi   
/etc/sysconfig/spawn-fcgi
/usr/bin/spawn-fcgi

```

/etc/rc.d/init.d/spawn-fcgi на основе него будем писать юнит в systemd для запуска данного сервиса

/etc/sysconfig/spawn-fcgi раскоментируем нужные нам опции.

/etc/systemd/system/spawn-fcgi.service полученный юнит в systemd

При первом запуске была полученна ошибка что не найден пользователь 'apache' для этого установим сам сервис 'apache'

```
yum -y install httpd

```

Все файлы расположенны в директории (spawn-fcgi).

#

## 3. Дополнить юнит-файл apache httpd возможностьб запустить несколько инстансов сервера с разными конфигами

#
Для того чтобы задействовать систему инстансов для дальнейшего запуска сервиса с различными параметрами или конфигами необходимо:

Скопировать основной юнит 

```

cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service

```
Подредактируем его

```

vim /etc/systemd/system/httpd\@.service

```

Исправим данную строку `EnvironmentFile=/etc/sysconfig/httpd-%i`


Далее скопируем конфиг самого апача и сделаем в нем неообходимые изменения

```

cp -vR /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-1.conf

```

Далее скопируем конфиг запуска юнита

```

cp -v /etc/sysconfig/httpd /etc/sysconfig/httpd-1

```

Отредактируем его ' OPTIONS="-f /etc/httpd/conf/httpd-1.conf" ' укажем в нем запуск с конкретным конфигом.

Далее запускаем сервис используя инстансы

```

systemctl start httpd@1.service
systemctl status httpd@1.service

```

Все файлы расположенны в директории (httpd).
