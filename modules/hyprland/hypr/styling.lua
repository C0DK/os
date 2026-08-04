local colors = require("catppuccin-frappe")

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
})

hl.config({
  scrolling = {
    column_width = 0.49,
    focus_fit_method = 1,
  },
})

hl.config({
  master = {
    new_status = "master",
  },
})

hl.config({
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
})

hl.config({
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
})

hl.config({
  animations = {
    enabled = true,
  },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })
