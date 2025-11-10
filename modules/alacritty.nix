{ user, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ alacritty ];
  home-manager.users.${user}.programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          # TODO: set font a single place
          family = "FiraCode Nerd Font";
        };
      };
      window = {
        opacity = 0.8;
        decorations = "full";
        dynamic_title = true;
      };

      colors = {
        primary = {
          background = "0x303446";
          foreground = "0xc6d0f5";
          dim_foreground = "0x838ba7";
          bright_foreground = "0xc6d0f5";
        };

        cursor = {
          text = "0x303446";
          cursor = "0xf2d5cf";
        };

        vi_mode_cursor = {
          text = "0x303446";
          cursor = "0xbabbf1";
        };

        search = {
          matches = {
            foreground = "0x303446";
            background = "0xa5adce";
          };
          focused_match = {
            foreground = "0x303446";
            background = "0xa6d189";
          };
        };

        footer_bar = {
          foreground = "0x303446";
          background = "0xa5adce";
        };

        hints = {
          start = {
            foreground = "0x303446";
            background = "0xe5c890";
          };
          end = {
            foreground = "0x303446";
            background = "0xa5adce";
          };
        };

        selection = {
          text = "0x303446";
          background = "0xf2d5cf";
        };

        normal = {
          black = "0x51576d";
          red = "0xe78284";
          green = "0xa6d189";
          yellow = "0xe5c890";
          blue = "0x8caaee";
          magenta = "0xf4b8e4";
          cyan = "0x81c8be";
          white = "0xb5bfe2";
        };

        bright = {
          black = "0x626880";
          red = "0xe78284";
          green = "0xa6d189";
          yellow = "0xe5c890";
          blue = "0x8caaee";
          magenta = "0xf4b8e4";
          cyan = "0x81c8be";
          white = "0xa5adce";
        };
      };
    };
  };
}
