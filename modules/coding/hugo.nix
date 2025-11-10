{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hugo
    go
  ];

}
