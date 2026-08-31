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

hl.curve("scratchBezier", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("wsSlide", { type = "bezier", points = { { 0.25, 0.8 }, { 0.25, 1 } } })
hl.curve("wsFade", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "scratchBezier", style = "slidevert" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "scratchBezier", style = "slidevert popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "scratchBezier", style = "slidevert popin 90%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "scratchBezier", style = "slidevert" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wsSlide", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5, bezier = "wsSlide", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5, bezier = "wsSlide", style = "slide" })
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
