#!/bin/bash

STATE_FILE="$HOME/.cache/theme-mode"
VIEW_STATE_FILE="$HOME/.cache/quickshell-theme-view"
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")

if [ -n "$1" ]; then
    NEW_MODE="$1"
else
    if [ "$CURRENT" = "dark" ]; then
        NEW_MODE="light"
    else
        NEW_MODE="dark"
    fi
fi

echo "$NEW_MODE" > "$STATE_FILE"

if [ -n "$2" ]; then
    printf '%s\n' "$2" > "$VIEW_STATE_FILE"
fi

WALLPAPER=$(cat "$HOME/.cache/current_wallpaper" 2>/dev/null)
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    if command -v awww &>/dev/null; then
        WALLPAPER=$(awww get-img 2>/dev/null | head -1)
    fi
fi
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER=$(find "$HOME/Pictures/wallpapers" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | head -1)
fi

if [ -d "$HOME/hyprland-config/.config/matugen/templates" ] && [ -d "$HOME/.config/matugen/templates" ]; then
    cp -r "$HOME/hyprland-config/.config/matugen/templates/"* "$HOME/.config/matugen/templates/" 2>/dev/null
fi

if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    matugen image "$WALLPAPER" --mode "$NEW_MODE" --source-color-index 0
fi

if [ -f "$HOME/.config/quickshell/Colors.qml" ] && [ -f "$HOME/hyprland-config/.config/quickshell/Colors.qml" ]; then
    cp "$HOME/.config/quickshell/Colors.qml" "$HOME/hyprland-config/.config/quickshell/Colors.qml" 2>/dev/null
fi

if command -v gsettings &>/dev/null; then
    CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
    [ -z "$CURRENT_THEME" ] && CURRENT_THEME="adw-gtk3"

    if [ "$NEW_MODE" = "light" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        if [[ "$CURRENT_THEME" == *"dark"* ]]; then
            gsettings set org.gnome.desktop.interface gtk-theme "${CURRENT_THEME/-dark/}"
        else
            gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"
        fi
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        if [[ "$CURRENT_THEME" != *"dark"* ]]; then
            gsettings set org.gnome.desktop.interface gtk-theme "${CURRENT_THEME}-dark"
        else
            gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_THEME"
        fi
    fi

    GTK_PREFERENCE=$([ "$NEW_MODE" = "light" ] && echo 0 || echo 1)
    GTK_THEME_NAME=$([ "$NEW_MODE" = "light" ] && echo Adwaita || echo Adwaita-dark)
    for GTK_CONFIG in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
        mkdir -p "$(dirname "$GTK_CONFIG")"
        if [ -f "$GTK_CONFIG" ]; then
            sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME_NAME/; s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$GTK_PREFERENCE/" "$GTK_CONFIG"
        else
            printf '[Settings]\ngtk-theme-name=%s\ngtk-application-prefer-dark-theme=%s\n' "$GTK_THEME_NAME" "$GTK_PREFERENCE" > "$GTK_CONFIG"
        fi
    done

    if command -v systemctl &>/dev/null && systemctl --user is-active --quiet xdg-desktop-portal-gtk; then
        systemctl --user restart xdg-desktop-portal-gtk &>/dev/null &
    fi
fi

if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null &
fi
