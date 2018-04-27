



	1. Написал скрипт "pre.sh" для предварительного создания виртуальных дисков нужного размера для Virtualbox.
	This script created and attached Virtual HDD from Virtual Box machine
	
	pre.sh create path name size

		create --- Created Virtual HDD

		path   --- Path from Virtual HDD file

		name   --- Name Virtual HDD

		size   --- Size Virtual HDD
	
	2. Написал скрипт "post_add_raid.sh" для последующего создания райда, с установкой пакета mdadm.
	
	3. Поправил Vagrantfile добавив там добавление необходимых виртуальных дисков нужного размера(альтернатива 1му скрипту).
	   Запусп скрипта "post_add_raid.sh" в провижине, после запуска машины.

