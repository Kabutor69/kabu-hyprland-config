#!/bin/bash

CHOICE="$1"

[ -z "$CHOICE" ] && exit 0

if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.2
fi

# 1. Set wallpaper
awww img "$CHOICE" \
    --transition-type wipe \
    --transition-angle 45 \
    --transition-fps 120 \
    --transition-duration 1 &

matugen image "$CHOICE" --source-color-index 0

CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
gsettings set org.gnome.desktop.interface gtk-theme ''
gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"

notify-send "Wallpaper Changed" "$(basename "$CHOICE")"
