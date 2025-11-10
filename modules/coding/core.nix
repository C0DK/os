{ config, pkgs, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      # Gihub CLI
      gh

      bat

      jq
      yq-go

      pgcli
    ];

}
