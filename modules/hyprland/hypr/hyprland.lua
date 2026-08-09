local programs = require("programs")


hl.monitor({
  output = "DP-11",
  mode = "preferred",
  position = "2560x0",
  scale = 1,
})

hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "0x0",
  scale = 1.07
})

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

hl.on("hyprland.start", function()
  hl.exec_cmd(programs.terminal)
  hl.exec_cmd("pkill waybar; waybar")
  hl.exec_cmd("pkill hyprpaper; hyprpaper")
  hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
  hl.exec_cmd("~/.config/hypr/scripts/groupbind")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

hl.env("HYPRCURSOR_THEME", "Future-Cyan-Hyprcursor_Theme")
hl.env("HYPRCURSOR_SIZE", "35")
hl.env("XCURSOR_SIZE", "35")

require("styling")

hl.config({
  misc = {
    force_default_wallpaper = 1,
    disable_hyprland_logo = false,
  },
})

hl.config({
  input = {
    kb_layout = "dk,us",
    kb_variant = "winkeys,altgr-intl",
    kb_model = "",
    kb_options = "grp:win_space_toggle",
    kb_rules = "",
    follow_mouse = 0,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

hl.device({
  name = "olkb-preonic",
  kb_layout = "us",
  kb_variant = "altgr-intl",
  kb_options = "",
})

hl.device({
  name = "olkb-preonic-keyboard",
  kb_layout = "us",
  kb_variant = "altgr-intl",
  kb_options = "",
})

require("binds")

hl.window_rule({
  name = "flameshot-multi-display-fix",
  match = { class = "flameshot" },
  animation = "fade",
  rounding = 0,
  border_size = 0,
  fullscreen_state = "0 0",
  float = true,
  pin = true,
  monitor = "DP-1",
  move = { 0, 0 },
  size = { "(monitor_w*3)", "(monitor_h)" },
})
