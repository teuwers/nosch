{ config, pkgs, ... }:

{
  imports =
    [ 
      .,/hardware-configuration.nix
      ../modules/base.nix
      ../modules/secure_boot.nix
      ../modules/pc.nix
      ../modules/plasma.nix
      ../modules/btrfs_root.nix
    ];

  hardware.cpu.intel.updateMicrocode = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  powerManagement.enable = true;

  time.hardwareClockInLocalTime = true;

  networking = {
    hostName = "prometheus";
    interfaces.enp1s0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
  };

  hardware.graphics = { 
    enable = true;
    extraPackages = with pkgs; [
      intel-media-sdk
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
