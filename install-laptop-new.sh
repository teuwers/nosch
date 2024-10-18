#!/usr/bin/env bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

umount -Rq /mnt
swapoff -a
cryptsetup -q luksClose crypted_nixos

# Partitioning
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart fat32 1M 500M
parted -s /dev/sda mkpart primary 500M 100%

#Formatting
nix-shell -p btrfs-progs
mkfs.vfat -n BOOT /dev/sda1

cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 nixos_crypted

mount -t btrfs /dev/mapper/nixos_crypted /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log
btrfs subvolume create /mnt/swap
# Take an empty *readonly* snapshot of the root subvolume, which can be rollback to on every boot.
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

umount /mnt

mount -o subvol=root,compress=zstd,noatime /dev/mapper/nixos_crypted /mnt
mkdir /mnt/home
mount -o subvol=home,compress=zstd,noatime /dev/mapper/nixos_crypted /mnt/home
mkdir /mnt/nix
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/nixos_crypted /mnt/nix
mkdir /mnt/persist
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/nixos_crypted /mnt/persist
mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime /dev/mapper/nixos_crypted /mnt/var/log

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

mkdir /mnt/swap
mount -o subvol=swap,noatime /dev/mapper/nixos_crypted /mnt/swap
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

git clone https://github.com/teuwers/nosch.git /mnt/etc/nixos
nixos-generate-config --root /mnt
rm /mnt/etc/nixos/configuration.nix

echo '  fileSystems = {
  "/".options = [ "compress=zstd" ];
  "/home".options = [ "compress=zstd" ];
  "/nix".options = [ "compress=zstd" "noatime" ];
  "/swap".options = [ "noatime" ];
  "/persist".options = [ "compress=zstd" "noatime" ];
  "/log".options = [ "compress=zstd" "noatime" ];
  };
  
  boot.supportedFilesystems = [ "btrfs" ];' >> /mnt/etc/nixos/hardware-configuration.nix

echo "Check UUIDS in /mnt/etc/nixos/hosts/notebook-hardware.nix then
nixos-install --impure --flake /mnt/etc/nixos#prometheus
Workaround for /etc bug:
sudo nixos-enter
nixos-install --root /"

nix flake update -I /mnt/etc/nixos/

echo "Check https://nixos.wiki/wiki/Btrfs"
