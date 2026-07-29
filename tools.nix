{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixfmt

    flameshot
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    grim

    git
    spotify
    nordic

    fd
    fzf

    chromium

    claude-code

    nautilus

    go-task

    gimp

    killall

    unzip
    zip

    dig

    htop
    glances

    wl-clipboard

    git-lfs

    # Run GitHub Actions workflows locally in a container
    act
  ];
}
