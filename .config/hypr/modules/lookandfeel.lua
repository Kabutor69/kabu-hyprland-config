local colors = require("colors.colors")


hl.config({
    general = {
        gaps_out = 5,
        gaps_in = 2,
        border_size = 1,
        col = {
           active_border = {
            colors = {
              colors.primary,
              colors.secondary
            },
        angle = 45,
        },

      inactive_border = colors.surface, 
      },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 0.90,
        inactive_opacity = 0.85,
        shadow = {
            enabled = true,
            range = 8,
            render_power = 4,
            color = "rgba(1b1d2bcc)",
        },
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
            noise = 0.01,
            contrast = 0.95,
            brightness = 0.9,
            vibrancy = 0.2,
            vibrancy_darkness = 0.3,
            popups = true,
            popups_ignorealpha = 0.2,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

hl.curve("smoothOut", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })
hl.curve("smoothInOut", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0 }, { 0.75, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "smoothOut", style = "slidevert" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.5, bezier = "smoothOut", style = "slidevert popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "smoothInOut", style = "slidevert popin 85%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, bezier = "smoothOut", style = "slidevert" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smoothInOut", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3, bezier = "smoothInOut", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3, bezier = "smoothInOut", style = "slide" })
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "smoothOut" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "smoothOut" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "smoothInOut" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.5, bezier = "smoothOut" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.5, bezier = "smoothOut" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.5, bezier = "smoothOut", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "smoothInOut", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3, bezier = "smoothInOut" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 5, bezier = "smoothOut" })
