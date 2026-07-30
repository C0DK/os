{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    pnpm
    typescript-language-server
    # html?
    superhtml
    htmltest
  ];

}
