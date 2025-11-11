{
  config,
  pkgs,
  lib,
  user,
  nixOsVersion,
  ...
}:
{

  home-manager.users.${user} = {
    # The home.stateVersion option does not have a default and must be set
    home.stateVersion = nixOsVersion;
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  i18n.extraLocaleSettings = {
    LC_TIME = "da_DK.UTF-8";
  };

  virtualisation.docker.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    pkgs.nerd-fonts.fira-code
  ];

  services.xserver = {
    excludePackages = [ pkgs.xterm ];
  };

  programs = {
    # Install firefox.
    firefox.enable = true;

  };
  # To enable password input etc
  services.gnome.gnome-keyring.enable = true;

  # disable all the default gnome apps
  services.gnome.core-apps.enable = false;

  # https://discourse.nixos.org/t/nixos-rebuild-switch-upgrade-networkmanager-wait-online-service-failure/30746
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # nix formatting tool
    pkgs.nixfmt-rfc-style

    git
    spotify
    nordic

    # fzf alternative
    television
    fzf

    # A visual file explorer is nice for removable disks
    nautilus

    # https://taskfile.dev/
    go-task

    gimp

    killall

    unzip
    zip

    dig

    htop
    glances # htop alternative

    wl-clipboard # write to clipboard from shell
  ];

  # Enable loading new qmk to keyboard
  hardware.keyboard.qmk.enable = true;

}
