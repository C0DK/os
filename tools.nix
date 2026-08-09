{
  pkgs,
  repoPath,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nixfmt
    treefmt

    flameshot
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    grim

    git
    spotify

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
    # TODO: prettier output

    # Wrapper so `system sync` / `system upgrade` / etc. work from any cwd
    (writeShellScriptBin "system" ''
      exec ${go-task}/bin/task -t ${repoPath}/taskfile.yml "$@"
    '')
  ];
}
