{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    go
    gopls
    gofumpt
    golangci-lint
  ];

}
