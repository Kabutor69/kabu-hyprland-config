-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon & hypridle & env QS_NO_RELOAD_POPUP=1 quickshell")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 16")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("sleep 3 && killall nm-applet")
end)

-- Environment Variables
hl.env("QS_NO_RELOAD_POPUP", "1")
hl.env("KDE_SESSION_VERSION", "5")
hl.env("KDE_FULL_SESSION", "true")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT6_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland")
-- hl.env("GTK_THEME", "Adwaita-dark")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "16")

