{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Gihub CLI
    gh

    bat

    jq
    yq-go

    bdt

    pgcli

    treefmt

    lldb
    # dotnet tool install --global dotnet-debugger-extensions

    bandwhich

  ];

}
