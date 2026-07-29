{
  pkgs,
  lib,
  user,
  nixOsVersion,
  ...
}:
{
  home-manager.users.${user} = {
    home.stateVersion = nixOsVersion;
  };

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  time.timeZone = "Europe/Copenhagen";

  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };

  console.keyMap = "dk-latin1";

  i18n.extraLocaleSettings = {
    LC_TIME = "da_DK.UTF-8";
  };

  virtualisation.docker.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts.fira-code
  ];

  services.xserver = {
    excludePackages = [ pkgs.xterm ];
  };

  services.gnome.gnome-keyring.enable = true;
  services.gnome.core-apps.enable = false;

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  hardware.keyboard.qmk.enable = true;
}
