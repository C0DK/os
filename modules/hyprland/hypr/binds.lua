local programs = require("programs")

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(programs.menu), { release = true })

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

local focusKeys = { left = "left", right = "right", up = "up", down = "down" }
for key, dir in pairs(focusKeys) do
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
end

local moveKeys = { left = "left", right = "right", K = "up", J = "down" }
for key, dir in pairs(moveKeys) do
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

local wsMonitorKeys = { left = "left", right = "right", h = "left", l = "right" }
for key, dir in pairs(wsMonitorKeys) do
  hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + " .. key, hl.dsp.workspace.move({ monitor = dir }))
end

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

local volumeCmds = {
  XF86AudioRaiseVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+",
  XF86AudioLowerVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
  XF86AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
}
for key, cmd in pairs(volumeCmds) do
  hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true, repeating = true })
end

local mediaCmds = {
  XF86AudioPlay = "playerctl play-pause",
  XF86AudioPause = "playerctl play-pause",
  XF86AudioNext = "playerctl next",
  XF86AudioPrev = "playerctl previous",
}
for key, cmd in pairs(mediaCmds) do
  hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true })
end

local brightnessCmds = {
  XF86MonBrightnessUP = "brightnessctl set 5%+",
  XF86MonBrightnessDown = "brightnessctl set 5%-",
}
for key, cmd in pairs(brightnessCmds) do
  hl.bind(key, hl.dsp.exec_cmd(cmd), { repeating = true })
end
