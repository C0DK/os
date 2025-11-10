{ pkgs, user, ... }:
{
  users.defaultUserShell = pkgs.nushell;

  environment.systemPackages = with pkgs; [
    nushellPlugins.polars
  ];

  home-manager.users.${user}.programs = {
    nushell =
      let
        nuDetNu = builtins.fetchGit {
          url = "https://github.com/LiHRaM/NuDetNu.git";
          rev = "646b8e80735c52a6e3fec66d0c31061c87650285";
        };
      in
      {
        enable = true;
        # for editing directly to config.nu
        extraConfig = ''
          source ${nuDetNu}/fzf.nu
          source ${nuDetNu}/tv.nu
          source ${nuDetNu}/dotenv.nu
          source ${nuDetNu}/dotnet.nu
        ''
        + builtins.readFile ./config.nu;
        shellAliases = {
          nixup = "sudo nixos-rebuild switch";
          nixchanup = "sudo nix-channel --update";
          nixupgrade = "sudo nixos-rebuild switch --upgrade";

          py = "python";
          la = "ls -a";
        };
      };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };
}
