{ user, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ghostty ];
  home-manager.users.${user} = {
    programs.ghostty = {
      enable = true;
      settings = {
        #font-family = "FiraCode Nerd Font";
        font-size = 10;
        background-opacity = 0.8;
        theme = "Catppuccin Frappe";
        shell-integration-features = "no-cursor";
        window-decoration = false;
        window-padding-color = "extend";
        cursor-style = "block";
        cursor-style-blink = false;
        scrollback-limit = 10000;
        copy-on-select = false;
        confirm-close-surface = false;
        command = "tmux new-session -A -s main";
      };
    };
  };
}
