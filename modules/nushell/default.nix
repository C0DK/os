{ pkgs, user, ... }:
{
  users.defaultUserShell = pkgs.nushell;

  environment.systemPackages = with pkgs; [
    # terminal completor
    carapace
    starship
    fastfetch
    # polars is broken. renabled when works
    #nushellPlugins.polars
  ];

  home-manager.users.${user}.programs = {
    nushell =
      let
        nuDetNu = builtins.fetchGit {
          url = "https://github.com/LiHRaM/NuDetNu.git";
          rev = "dfdaa5f74ef79a39bda96f945cdea9ac9b0ed7f0";
        };
      in
      {
        enable = true;
        # for editing directly to config.nu
        extraConfig = ''
          mkdir ($nu.data-dir | path join "vendor/autoload")
          tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")

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
          k9s = "with-env { TERM: screen-256color } { ^k9s }";
        };
      };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;

      settings = {
        # all options:
        # https://gist.github.com/s-a-c/0e44dc7766922308924812d4c019b109#file-starship-nix/
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        git_commit = {
          commit_hash_length = 7;
          format = "[($hash$tag)]($style) ";
          style = "purple italic dimmed";
          only_detached = false;
          disabled = false;
          tag_symbol = " 🏷  ";
          tag_disabled = true;
        };
      };
    };
  };
}
