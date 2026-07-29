{
  config,
  pkgs,
  user,
  ...
}:
{
  home-manager.users.${user} = {
    home.packages = [ pkgs.television ];
  };
  imports = [
    ./cables/dotnet-projects.nix
    ./cables/files.nix
    ./cables/git.nix
    ./cables/docker.nix
    ./cables/gh.nix
    ./cables/system.nix
    ./cables/channels.nix
    ./config.nix
    ./theme.nix
  ];
}
