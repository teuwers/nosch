{ config, pkgs, ... }:
{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /mnt
    mount -t btrfs /dev/mapper/enc /mnt
    btrfs subvolume delete /mnt/root
    btrfs subvolume snapshot /mnt/root-blank /mnt/root
  '';
  
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
