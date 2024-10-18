#!/usr/bin/env bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

umount -Rq /mnt
swapoff -a
cryptsetup -q luksClose crypted-nixos
cryptsetup -q luksClose crypted-swap

dd if=/dev/urandom of=./keyfile-root.bin bs=1024 count=4
dd if=/dev/urandom of=./keyfile-swap.bin bs=1024 count=4

# Partitioning
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart fat32 1M 500M
parted -s /dev/sda set 1 esp on

parted -s /dev/sda mkpart primary 500M 20.5G
parted -s /dev/sda mkpart primary 20.5G 100%

mkfs.fat -F 32 /dev/sda1

#stty -echo
#read -p "Type password for LUKS partition:" LUKS_PASS; echo
#stty echo

#echo $LUKS_PASS | cryptsetup -q luksFormat --type luks1 -c aes-xts-plain64 -s 256 -h sha512 /dev/sda3 -d -
#echo $LUKS_PASS | cryptsetup -q luksAddKey /dev/sda3 keyfile-root.bin -d -
cryptsetup -q luksFormat --type luks1 -c aes-xts-plain64 -s 256 -h sha512 /dev/sda3 -d -
cryptsetup -q luksAddKey /dev/sda3 keyfile-root.bin -d -
cryptsetup -q luksOpen /dev/sda3 crypted-nixos -d keyfile-root.bin 

cryptsetup -q luksFormat -c aes-xts-plain64 -s 256 -h sha512 /dev/sda2 -d keyfile-swap.bin
cryptsetup -q luksOpen /dev/sda2 crypted-swap -d keyfile-swap.bin

mkfs.ext4 -L root /dev/mapper/crypted-nixos
mkswap -L swap /dev/mapper/crypted-swap
mount /dev/mapper/crypted-nixos /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
swapon /dev/mapper/crypted-swap

mkdir -p /mnt/etc/secrets/initrd/
mv -t /mnt/etc/secrets/initrd/ keyfile-root.bin keyfile-swap.bin
chmod 000 /mnt/etc/secrets/initrd/keyfile*.bin

git clone https://github.com/teuwers/nosch.git /mnt/etc/nixos
nixos-generate-config --root /mnt
rm /mnt/etc/nixos/configuration.nix

SDA2_UUID=$(blkid -s UUID -o value /dev/sda2)
SDA3_UUID=$(blkid -s UUID -o value /dev/sda3)
echo '  boot.initrd = {
    luks.devices."crypted-nixos" = { 
      device = "/dev/disk/by-uuid/'$SDA3_UUID'";
      keyFile = "/keyfile-root.bin";
      allowDiscards = true;
    };
    luks.devices."crypted-swap" = {
      device = "/dev/disk/by-uuid/'$SDA2_UUID'";
      keyFile = "/keyfile-swap.bin";
      allowDiscards = true;
    };
    secrets = {
      "keyfile-root.bin" = "/etc/secrets/initrd/keyfile-root.bin";
      "keyfile-swap.bin" = "/etc/secrets/initrd/keyfile-swap.bin";
    };
  };' >> /mnt/etc/nixos/hardware-configuration.nix

echo "Check UUIDS in /mnt/etc/nixos/hosts/notebook-hardware.nix then
nixos-install --impure --flake /mnt/etc/nixos#prometheus
Workaround for /etc bug:
sudo nixos-enter
nixos-install --root /"

nix flake update -I /mnt/etc/nixos/
