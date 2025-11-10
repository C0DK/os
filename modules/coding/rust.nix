{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rustup
    rustc
    gcc
  ];

}
