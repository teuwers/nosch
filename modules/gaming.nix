{ config, pkgs, ... }:

{
  imports =
    [ 
      #./wine-ge.nix
    ];
  
  environment.systemPackages = with pkgs; [
    xboxdrv
    prismlauncher
    zulu17
    jre8
  ];
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id === "org.freedesktop.NetworkManager.settings.modify.system") {
        var name = polkit.spawn(["cat", "/proc/" + subject.pid + "/comm"]);
        if (name.includes("steam")) {
          polkit.log("ignoring steam NM prompt");
          return polkit.Result.NO;
        }
      }
    });
  '';

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
    trustedInterfaces = [ "wlan0" ];
  };

  services.logmein-hamachi.enable = true;
  programs.haguichi.enable = true;
}
