{ config, pkgs, ... }:

{

#### System

  system.stateVersion = "24.05";
  services.fwupd.enable = true;
  nixpkgs.config.allowUnfree = true;
  
#### Remove old generations

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  nix.settings.auto-optimise-store = true;
  
#### Autoupgrade

  system.autoUpgrade.enable = true; 

#### Timezone and locale

  i18n = {
    glibcLocales = pkgs.glibcLocales;
    defaultLocale = "ru_RU.UTF-8";
    supportedLocales = 
    [  "ru_RU.UTF-8/UTF-8"
       "en_US.UTF-8/UTF-8"
    ];
  };
  
  services.ntp.enable = true;
  services.localtimed.enable = true;
  services.geoclue2.enable = true;
  
#### SSH
  
  services.sshd.enable = true;
  programs.ssh.startAgent = true;
  
#### TRIM

  services.fstrim.enable = true;
  
#### ZRAM
  
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  
#### Packages

  environment.systemPackages = with pkgs; [
    git
    lsd
    bat
    rsync
    wget
    neofetch
    zenith
    killall
    p7zip
    mime-types
    shared-mime-info
    unrar
    parted
    nixfmt
  ];
  
#### Fonts

  fonts = {
    enableDefaultPackages = true;
    packages = [ pkgs.nerdfonts ];
    fontconfig = {
      defaultFonts = {
        serif = [ "NotoSerif Nerd Font" ];
        sansSerif = [ "NotoSans Nerd Font" ];
        monospace = [ "NotoSansMono Nerd Font Mono" ];
      };
    };
  };

#### Console

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "ru";
  };

  users.extraUsers.root.shell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.zsh = {
    enable = true;
    zsh-autoenv.enable = true;
    autosuggestions = {
      enable = true;
      strategy = [ "completion" ];
    };
    shellAliases = {
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      diff = "diff --color=auto";
      ls = "lsd --group-dirs first";
      tree = "lsd --tree";
      top = "zenith";
      htop = "zenith";
      bat = "bat --theme=ansi-dark";
      cat = "bat --pager=never";
    };
    ohMyZsh = {
      enable = true;
      theme = "ys";
      plugins = [
        "adb"
        "colored-man-pages"
        "command-not-found"
        "thefuck"
      ];
    };
  };
  programs.thefuck.enable = true;
}
