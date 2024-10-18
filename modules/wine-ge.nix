{ config, pkgs, ... }:
let
  nix-gaming = import (builtins.fetchTarball "https://github.com/fufexan/nix-gaming/archive/master.tar.gz");
in
{
  # import the low latency module
  imports = [
    "${nix-gaming}/modules/pipewireLowLatency.nix"
  ];
  
  environment.systemPackages = [ 
    nix-gaming.packages.x86_64-linux.wine-ge
    winetricks
  ];

  services.pipewire = {
    enable = true;
    # alsa is optional
    alsa.enable = true;
    alsa.support32Bit = true;
    # needed for osu
    pulse.enable = true;
    lowLatency.enable = true;
    lowLatency = {
      quantum = 64;
      rate = 48000;
    };
  };
  
  security.rtkit.enable = true;
  
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };
}
