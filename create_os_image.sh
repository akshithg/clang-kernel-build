#!/bin/bash

# Create a minimal Debian-buster distributive as a directory
set -eux

mkdir -p buster
sudo rm -rf buster/*
sudo debootstrap --include=openssh-server buster buster

# Enable promtless ssh to the machine for root with RSA keys
sudo sed -i '/^root/ { s/:x:/::/ }' buster/etc/passwd
echo 'V0:23:respawn:/sbin/getty 115200 hvc0' | sudo tee -a buster/etc/inittab
printf '\nauto eth0\niface eth0 inet dhcp\n' | sudo tee -a buster/etc/network/interfaces
sudo mkdir buster/root/.ssh/
mkdir -p ssh
rm -rf ssh/*
ssh-keygen -f ssh/id_rsa -t rsa -N ''
cat ssh/id_rsa.pub | sudo tee buster/root/.ssh/authorized_keys

# Download and install trinity and other utils
sudo chroot buster /bin/bash -c "apt-get update; ( yes | apt-get install time trinity)"

# Build a disk image
dd if=/dev/zero of=linux.img bs=1M seek=511 count=1
mkfs.ext4 -F linux.img
sudo mkdir -p /mnt/buster
sudo mount -o loop linux.img /mnt/buster
sudo cp -a buster/. /mnt/buster/.
sudo umount /mnt/buster
