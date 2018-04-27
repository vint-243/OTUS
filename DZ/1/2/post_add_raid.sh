#!/usr/bin/env bash

echo 
echo "Install mdadm"

sudo yum -y install mdadm  

echo
echo "Add parted"

sleep 5

parted -s /dev/sdb mklabel gpt && parted -s /dev/sdb mkpart 1 1 100%
parted -s /dev/sdc mklabel gpt && parted -s /dev/sdc mkpart 1 1 100%

echo
echo "Create RAID"

sleep 5
mdadm --create /dev/md0 --level=0  --raid-devices=2 /dev/sd[b,c]1

mdadm  --detail /dev/md0

parted -s /dev/md0 mklabel gpt

echo
echo "Create parted"

parted -s /dev/md0 mkpart 1 ext4  1 10%
parted -s /dev/md0 mkpart 2 ext4  10% 20%
parted -s /dev/md0 mkpart 3 ext4  20% 40%
parted -s /dev/md0 mkpart 4 ext4  40% 60%
parted -s /dev/md0 mkpart 5 ext4  60% 100%

mkfs.ext4 /dev/md0p1
mkfs.ext4 /dev/md0p2
mkfs.ext4 /dev/md0p3
mkfs.ext4 /dev/md0p4
mkfs.ext4 /dev/md0p5

echo
echo "SHow parted from RAID"
parted -l /dev/md0

echo
echo "Creation Time = `mdadm  --detail /dev/md0 | grep 'Creation Time'`"
echo "RAID Size = `mdadm  --detail /dev/md0 | grep 'Array Size'`"
echo "Chunk Size = `mdadm  --detail /dev/md0 | grep 'Chunk Size'`"
echo "Device from RAID "
mdadm  --detail /dev/md0 | tail -2
