{ config, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  
#  environment.variables = {
#    SDL_VIDEODRIVER = "wayland";
#    QT_QPA_PLATFORM = "wayland";
#    MOZ_ENABLE_WAYLAND = "1";
#    GDK_BACKEND = "wayland";
#  };
  
  qt5.enable = true;
  qt5.platformTheme = "gnome";
  
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  
  environment.systemPackages = with pkgs; [
   #GNOME stuff
    qgnomeplatform
    gnome.gnome-tweaks
    gnome.gnome-shell-extensions
    gnomeExtensions.night-theme-switcher
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.appindicator
    gnomeExtensions.espresso
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.material-shell
    celluloid
    evolution
    #gnome.gedit
    gnome-text-editor
    gnome.gnome-terminal
  ];
  
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
    epiphany
    xterm
 #   gnome-text-editor
    gnome-console
  ]);
  
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  programs.ssh.hostKeyAlgorithms = [ "ssh-rsa" ];

} 
