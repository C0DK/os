local colors = require("catppuccin-frappe")

hl.monitor({
  output = "DP-13",
  mode = "preferred",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = "DP-11",
  mode = "preferred",
  position = "2560x0",
  scale = 1,
})

hl.monitor({
  output = "DP-9",
  mode = "preferred",
  position = "5120x0",
  scale = 1,
})

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "pkill wofi || wofi --show=drun --conf ~/.config/wofi/config --style ~/.config/wofi/style.css"

hl.on("hyprland.start", function()
  hl.exec_cmd(terminal)
  hl.exec_cmd("pkill waybar; waybar")
  hl.exec_cmd("pkill hyprpaper; hyprpaper")
  hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
  hl.exec_cmd("~/.config/hypr/scripts/groupbind")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

hl.env("HYPRCURSOR_THEME", "Future-Cyan-Hyprcursor_Theme")
hl.env("HYPRCURSOR_SIZE", "35")
hl.env("XCURSOR_SIZE", "35")

hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 16,
    border_size = 2,
    col = {
      active_border = { colors = { colors.base, colors.base }, angle = 45 },
      inactive_border = colors.base,
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "scrolling",
  },
  scrolling = {
    column_width = 0.49,
    focus_fit_method = 1,
  },
  master = {
    new_status = "master",
  },
  group = {
    col = {
      border_active = { colors = { colors.rosewater, colors.mauve }, angle = 45 },
      border_inactive = colors.base,
    },
    groupbar = {
      font_size = 12,
      text_color = colors.text,
      col = {
        active = colors.surface0,
        inactive = colors.crust,
      },
      gradients = true,
    },
  },
  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
  misc = {
    force_default_wallpaper = 1,
    disable_hyprland_logo = false,
  },
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

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(menu), { release = true })

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + left", hl.dsp.workspace.move({ monitor = "left" }))
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + right", hl.dsp.workspace.move({ monitor = "right" }))
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + h", hl.dsp.workspace.move({ monitor = "left" }))
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + l", hl.dsp.workspace.move({ monitor = "right" }))

hl.bind(mainMod .. " + SHIFT + g", hl.dsp.group.toggle())
hl.bind(mainMod .. " + g", hl.dsp.group.next())

for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_up", hl.dsp.layout("move +100"))
hl.bind(mainMod .. " + mouse_down", hl.dsp.layout("move -100"))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previou"), { locked = true })
hl.bind("XF86MonBrightnessUP", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

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
