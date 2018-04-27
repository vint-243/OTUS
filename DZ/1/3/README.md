

	1. Уменьшить том под / до 8G

	Выполнение данного задания осуществлял на рабочей ОСи загруженной в штатном режиме, осуществляя перенос на вновь созданный временный логический том root'а.
	Устанавливаем xfsdump для снятия дампа с оригинального тома root'a так как fs на нем xfs.
```
	yum install -y xfsdump
```
	Создаем новую виртуальную и логическую группу томов, на дополнительном hdd.
	Снимаем дамп с реального тома, далее восстанавливаем его на новый том.
```
pvcreate /dev/sdb
vgcreate os /dev/sdb
lvcreate -n new_root -l +100%FREE os
mkfs.xfs /dev/os/new_root
mkdir /mnt/os
mount /dev/os/new_root /mnt/os
xfsdump -f /tmp/old_root.dump /dev/VolGroup00/LogVol00
xfsrestore -f /tmp/old_root.dump /mnt/os
```
<br>	После этого правим конфиг grub.cfg

```bash
$ for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/os/$i; done
$ chroot /mnt/os
$ grub2-mkconfig -o /boot/grub2/grub.cfg
$ cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
	Изменяем значение `rd.lvm.lv=VolGroup00/LogVol00` на `rd.lvm.lv=os/new_root`.

	Делаем ребут с загрузкой с тового тома.
	Далее изменяем размер оригинального тома и переносим корень на него обратно.
	
```bash
#Удаляем старую логическую группу и создаем новую формотируя ее в xfs
lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt/os
#Создаем заново дамп c корня, только предварительно удалив старый дамп.
rm -v /tmp/old_root.dump
xfsdump -f /tmp/old_root.dump /dev/os/new_root
xfsrestore -f /tmp/old_root.dump /mnt/os
```
<br>    После этого правим конфиг grub.cfg

```bash
$ for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/os/$i; done
$ chroot /mnt/os
$ grub2-mkconfig -o /boot/grub2/grub.cfg
$ cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
Сразу же сделаем том под /var в mirror

```bash
pvcreate /dev/sdc /dev/sdd
vgcreate os_var /dev/sdc /dev/sdd
lvcreate -n var -L 2G -m1 os_var
mkfs.ext4 /dev/os_var/var
mkdir /mnt/n_var
mount /dev/os_var/var /mnt/n_var
cp -avR /var/* /mnt/n_var
mkdir /tmp/var
mv /var/* /tmp/var
umount /mnt/n_var
mount /dev/os_var/var /var
```
Правим fstab с монтированием нового тома для /var
Ребутимся и удалем временный виртуальный том.
```bash
lvremove /dev/os/new_root
vgremove /dev/os
pvremove /dev/sdb
```

	2. Выделить том под /home
	
```bash
lvcreate -n home -L 4G VolGroup00
mkfs.xfs /dev/VolGroup00/home
mount /dev/VolGroup00/home /mnt/
cp -avR /home/* /mnt/
rm -vR /home/*
umount /mnt
mount /dev/VolGroup00/home /home/
```

```
Подправим fstab для монтирования /home раздела.
Выполняем работу в /home  со снэпшотами.

#Создаем файлы в директории /home/

touch /home/{0..50}

#Создаем снэпшот с /home 
lvcreate -L 4GB -s -n home_s /dev/VolGroup00/home

# Удаляем часть файлов
rm -v /home/{20..30}

# Восстанавливаемся со снэпшота, отмонтируя /home
umount /home
lvconvert --merge /dev/VolGroup00/home_s
mount /home
```


