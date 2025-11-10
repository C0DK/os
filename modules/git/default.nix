{ config, user, pkgs, ... }:
{
  home-manager.users.${user}.programs.git = {
    enable = true;
    userEmail = "c@cwb.dk";
    userName = "Casper Weiss Bang";
    signing = {
      key = "2E1DC0FF50920EDDDE1757D9881239F715822BB7";
    };
    aliases = {
      pr = "!f() { git push && gh pr create --fill-verbose; }; f";
      pra = "!f() { git push && gh pr create --fill-verbose --auto; }; f";
    };
    includes = [
      { path = ./gitconfig; }
    ];
  };
}
