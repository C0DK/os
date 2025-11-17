{
  pkgs,
  user,
  ...
}:
{
  programs = {
    hyprland.enable = true;
    waybar.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wofi
    hyprshot
    hyprcursor
    hyprpaper
    brightnessctl
    tuigreet
    # used for groupbind script
    socat
    libnotify
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
  # To launch hyprland on boot
  services.greetd =
    let
      tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
    in
    {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${tuigreet} --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
          # TODO as variable
          user = "cwb";
        };
        default_session = initial_session;
      };
    };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  home-manager.users.${user} = {
    programs = {

      hyprlock = {
        enable = true;
        settings = {
          general = {
            disable_loading_bar = true;
            grace = 0;
            hide_cursor = true;
            no_fade_in = false;
          };

          background = [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
            }
          ];

          input-field = [
            {
              size = "200, 50";
              position = "0, -80";
              monitor = "";
              dots_center = true;
              fade_on_empty = false;
              font_color = "rgb(202, 211, 245)";
              inner_color = "rgb(91, 96, 120)";
              outer_color = "rgb(24, 25, 38)";
              outline_thickness = 5;
              placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
              shadow_passes = 2;
            }
          ];
        };
      };
    };

    home.file =
      let
        cpy = folder: {
          source = folder;
          recursive = true;
          force = true;
        };
      in
      {
        ".config/waybar/" = cpy ./waybar;
        ".config/hypr" = cpy ./hypr;
        ".config/wofi" = cpy ./wofi;
      };
    services = {
      hyprpaper = (
        let
          # TODO: find easier way not dependend on username
          wallpaper = /home/cwb/.config/wallpaper.png;
        in
        {
          enable = true;
          settings = {

            wallpaper = [
              {
                monitor = "";
                path = builtins.toString wallpaper;
                fit_mode = "cover";
              }
            ];
            ipc = "off";
            splash = true;
            preload = (builtins.toString wallpaper);
          };
        }
      );
      # TODO style mako
      mako = {
        enable = true;
        #catppuccin.enable = true;
        settings = {
          actions = true;
          anchor = "top-right";
          border-radius = 8;
          border-size = 1;
          default-timeout = 10000;
          icons = true;
          #background-color = "#303446";
          #text-color = "#c6d0f5";
          #border-color = "#eebebe";
          #progress-color = "over #414559";

          #[urgency=high]
          #border-color=#ef9f76
          layer = "overlay";
          max-visible = 3;
          padding = "10";
          width = 300;
        };
      };

    };
  };
}
