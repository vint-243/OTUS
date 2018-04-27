#!/bin/bash


path_hdd=$2

name=$3
size=$4

cd $path_hdd

if [[ $1 == 'create' ]] ; then

	echo 
	echo "Create Virtual HDD to $path_hdd/$name.vmdk size $size Mb " 

	VBoxManage createhd --filename $name --format VMDK --size $size
	
	echo 
        echo "Virtual HDD Created"
	
	echo 
        echo "This list Virtual Machine"

	VBoxManage list vms
	
	echo 
        echo "Enter name Virtual Machine"

	echo "Virtual Machine=" && read name_vms
	
	echo 
        echo "Select Virtual Machine $name_vms"
	echo "SATA port busy"
	
	VBoxManage showvminfo $name_vms | grep SATA
	
	echo 
        echo "Enter number free SATA port "
	echo "Number port=" && read port_num

	echo 
        echo "Select free SATA port $port_num"

	echo "Attaching Virtual HDD $name from SATA port $port_num"
	
	VBoxManage storageattach "$name_vms" --storagectl "SATA" --port $port_num --device 0 --type hdd --medium $path_hdd/$name.vmdk

	echo "Attached Virtual HDD $name from SATA port $port_num  DONE"

	VBoxManage showvminfo $name_vms | grep SATA

	echo
	echo "Created and attached Virtual HDD $name DONE"

	echo


      else

	echo
	echo "This script created and attached Virtual HDD from Virtual Box machine"

	echo 
	echo
	echo "pre.sh create path name size"

	echo
	echo
	echo "		create --- Created Virtual HDD"
	echo
	echo "		path   --- Path from Virtual HDD file"
	echo
	echo "		name   --- Name Virtual HDD"
	echo
	echo "		size   --- Size Virtual HDD" 

	echo

fi


