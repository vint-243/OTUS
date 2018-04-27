

	1. Попасть в систему без пароля несколькими способами

	Во время загрузки grub после появления списка загрузки нажимаем на "e" попадаем в редактор скрипта загрузки grub2. Находим секцию загрузки нужного нам меню. Правим основную строку загрузки ядра системы "linux16 /vmlinuz-3.10.0-693.el7.x86_64 root=/dev/mapper/centosnew-root ro crashkernel=auto rd.lvm.lv=centosnew/root rd.lvm.lv=centosnew/swap rhgb quiet LANG=ru_RU.UTF-8"  меняем "ro" на "rw init=/sysroot/bin/bash" паосле этого оказываемся в терминале BASH с примонтированным корнем в /sysroot, можно произвести смену корня при помощи "chroot /sysroot /bin/bash" далее, создаем файл для SElinux "touch /.autorelabel" можем сменить пароль если это требуется. Далее выходим с реального корня, отмонтируем его и можно выполнить ребут для проверки выполненных действий.
	Еще способ : заменяем "rhgb quiet" на "rd.break enforcing=0" попадаем в консоль системы с примонтированным корнем в "/sysroot" можем произвести смену корня таким же способом что и выше "chroot /sysroot /bin/bash", работа ни чем не ограниченна, единственное пробовал сменить пароль в таком режиме получил ошибку "Ошибка при выполнении операции с маркером подлиности. Ошибка доступа".
	Еще способ который не сработал на CentOS загрузится в single режиме : дописывал в конце строки "single", заменял даже "rhgb quiet" на "subgle" не проканало, загружается Single режим но без пароля рута нечего делать, никакой не подходит кроме оригинального.

	2. Установить систему с LVM, после чего переименовать VG

	Производил загрузку така же как и при загрузки системы без пароля:
	Меняем "ro" на "rw init=/sysroot/bin/bash" паосле этого оказываемся в терминале BASH с примонтированным корнем в /sysroot, примонтировал "mount --bind /dev /sysroot/dev && mount --bind /proc /sysroot/proc && mount --bind /sys /sysroot/sys"  произвел смену корня при помощи "chroot /sysroot /bin/bash". 
	После этого выполнил команду "vgrename centos centosnew"
	Далее отредактировал конфиг /etc/grub2.cfg и /etc/fstab чтобы загрузится с новой Виртуальной группы.

```
[root@localhost vint]# vgdisplay
  --- Volume group ---
  VG Name               centosnew
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <14,00 GiB
  PE Size               4,00 MiB
  Total PE              3583
  Alloc PE / Size       3583 / <14,00 GiB
  Free  PE / Size       0 / 0
  VG UUID               kQD0io-q2NV-GwAv-CtIw-ILk5-GWsH-Xge7fY

```
```
[root@localhost vint]# grep centosnew /etc/grub2.cfg
	linux16 /vmlinuz-3.10.0-693.el7.x86_64 root=/dev/mapper/centosnew-root ro crashkernel=auto rd.lvm.lv=centosnew/root rd.lvm.lv=centosnew/swap rhgb quiet LANG=ru_RU.UTF-8

[root@localhost vint]# grep centosnew /etc/fstab
/dev/mapper/centosnew-root /                       xfs     defaults        0 0
/dev/mapper/centosnew-swap swap                    swap    defaults        0 0

```



	3. Добавить модуль в initrd

	Особо заморачиваться не стал, взял шаблонный скрипт из методички


```
cat /usr/lib/dracut/modules.d/01test/test.sh 
#!/bin/bash
exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend




        ___________________
       < I'm dracut module >
        -------------------
         \
	  \
	    .--.
	   |o_o |
	   |:_/ |
	  //   \ \
	 (|     | )
	/'\_   _/`\
	\___)=(___/
msgend
sleep 10
echo " continuing....

```


	Далее сохранил оригинальный initramfs мало ли криво соберется.

	cp -p /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak

	Запустил "dracut" для автоматической сборки и чтобы не было сюрпризов указал вручную точную версию ядра

	dracut -f /boot/initramfs-3.10.0-693.el7.x86_64.img 3.10.0-693.el7.x86_64

```
	[root@localhost 01test]# ls -la /boot/ | grep  "initramfs-`uname -r`*"
-rw-------.  1 root root 20414315 май 10 23:43 initramfs-3.10.0-693.el7.x86_64.img
-rw-------.  1 root root 20860539 май 10 20:06 initramfs-3.10.0-693.el7.x86_64.img.bak

```
	Машина подорвалась без проблем.

	4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m

	Пример конфига grub.cfg	


```


menuentry 'CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d1bc3d92-7d41-48c9-8fe5-a80133a6fe8d' {
        load_video
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod xfs
	insmod lvm
#        set root='hd0,msdos1'
	set root='lvm/3l2Hhs-HIiv-uaf8-JG6i-vFZi-2dh1-WUfLpN'  #  VG repo нужно указывать UUID или всетаки имя
        if [ x$feature_platform_search_hint = xy ]; then
          search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1 --hint='hd0,msdos1'  8123619f-3eb2-49d1-9c7d-b0866946a0bf # UUID dm2
        else
          search --no-floppy --fs-uuid --set=root 8123619f-3eb2-49d1-9c7d-b0866946a0bf
        fi
        linux16 /vmlinuz-3.10.0-693.el7.x86_64 root=/dev/mapper/centosnew-root ro crashkernel=auto rd.lvm.lv=centosnew/root rd.lvm.lv=centosnew/swap  quiet LANG=ru_RU.UTF-8
        initrd16 /initramfs-3.10.0-693.el7.x86_64.img
}


```
###########################

```
LV Path                /dev/repo/lvol0
LV Name                lvol0
VG Name                repo

```
