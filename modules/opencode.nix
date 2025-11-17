{ user, pkgs, ... }:
{
  home-manager.users.${user} = {
    home.packages = [ pkgs.opencode ];

    xdg.configFile."opencode/config.json" = {
      force = true;
      source = (pkgs.formats.json { }).generate "opencode-config.json" {
        "$schema" = "https://opencode.ai/config.json";
        lsp = true;

        formatter = true;

        permission = {
          bash = {
            "git commit *" = "deny";
            "git push *" = "deny";
          };
        };
      };
    };
  };
}
