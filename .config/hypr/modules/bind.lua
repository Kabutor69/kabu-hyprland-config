local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local app_drawer = "qs ipc call drawer toggle"
local browser = "librewolf"
local control_center = "qs ipc call controlcenter toggle"
local notifcenter = "qs ipc call notifcenter toggle"
local wallpaper_switcher = "qs ipc call wallpaper toggle"
local clipboard = "qs ipc call clipboard toggle"
local power_option = "qs ipc call power toggle"

-- Keybinds
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(power_option))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(app_drawer))
hl.bind(mainMod .. " + SPACE", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("codium"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("vesktop"))
hl.bind(mainMod .. " + CTRL + T", hl.dsp.exec_cmd(wallpaper_switcher))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd([[mkdir -p ~/Pictures/Screenshots && grim - | tee ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy --type image/png]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy --type image/png]]))

-- Utilities
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(clipboard))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd(control_center))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(notifcenter))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd("qs ipc call systemmonitor toggle"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/kabutor/scripts/record.sh"))
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 3, action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin({ action = "toggle" }))

-- Directional focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + ALT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = "10", follow = false }))

-- Layout and scratchpad controls
hl.bind(mainMod .. " + semicolon", hl.dsp.layout("splitratio -0.1"))
hl.bind(mainMod .. " + apostrophe", hl.dsp.layout("splitratio +0.1"))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys (bindel/bindl)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
