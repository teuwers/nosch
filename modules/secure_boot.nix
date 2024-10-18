{ config, pkgs, ... }: 
{
  boot.initrd.systemd.enable = true;  # For auto unlock
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  environment.systemPackages = with pkgs; [
    sbctl  # for key management
  ];
}
