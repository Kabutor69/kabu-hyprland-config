# Hyprland Rice Setup Guide

This folder contains a custom Hyprland desktop setup using:

- Hyprland
- Quickshell
- Kitty
- zsh + Starship
- Qt5/Qt6 theming
- SDDM theme
- custom scripts and wallpaper pack

This README explains what to install, how to copy the config, and what commands you need to run to make the rice work.

---

## Preview

Check out the rice in action:

<video src="./Preview/preview.mp4" controls width="100%"></video>

---

## 1) Install the required system packages

This rice is made for Arch Linux / Arch-based systems. Install the main packages first:

```bash
sudo pacman -S --needed \
  hyprland \
  hypridle \
  hyprlock \
  kitty \
  zsh \
  starship \
  qt5ct \
  qt6ct \
  fzf \
  fastfetch \
  btop \
  cava \
  dolphin \
  grim \
  slurp \
  wl-clipboard \
  brightnessctl \
  playerctl \
  cliphist \
  matugen \
  awww \
  neovim \
  git \
  networkmanager \
  pipewire \
  wireplumber \
  pavucontrol \
  xdg-desktop-portal-hyprland
```

If your distro does not have a package in the repo, install it from the AUR, for example:

```bash
paru -S quickshell librewolf codium vesktop \
  bibata-cursor-theme zsh-autosuggestions zsh-syntax-highlighting
```

If you use `yay` instead of `paru`:

```bash
yay -S quickshell librewolf codium vesktop \
  bibata-cursor-theme zsh-autosuggestions zsh-syntax-highlighting
```

### Very important
The config expects these tools to exist:

- `hyprland`
- `hypridle`
- `hyprlock`
- `quickshell`
- `kitty`
- `librewolf`
- `dolphin`
- `codium`
- `vesktop`
- `cliphist`
- `grim`
- `slurp`
- `wl-copy`
- `brightnessctl`
- `playerctl`
- `matugen`
- `awww`
- `fastfetch`
- `starship`
- `fzf`

---

## 2) Backup your current config first

If you already have a desktop setup, backup it before overwriting anything:

```bash
cp -a ~/.config ~/.config-backup-$(date +%F-%H-%M-%S) 2>/dev/null || true
cp -a ~/.local ~/.local-backup-$(date +%F-%H-%M-%S) 2>/dev/null || true
cp -a ~/.zshrc ~/.zshrc-backup-$(date +%F-%H-%M-%S) 2>/dev/null || true
```

---

## 3) Copy the config into place

From the folder that contains this README, run:

```bash
mkdir -p ~/.config ~/.local ~/Pictures

cp -a ./ .config/. ~/.config/
cp -a ./ .local/. ~/.local/
cp -a ./.zshrc ~/.zshrc
cp -a ./Pictures/wallpapers ~/Pictures/
```

If you want to be more explicit, this is the same idea:

```bash
cp -a ./.config/. ~/.config/
cp -a ./.local/. ~/.local/
cp -a ./.zshrc ~/.zshrc
cp -a ./Pictures/wallpapers ~/Pictures/
```

### Install the SDDM theme

This rice includes a custom SDDM theme in `usr/share/sddm/themes/kabu`.

Copy it to the system theme directory:

```bash
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r ./usr/share/sddm/themes/kabu /usr/share/sddm/themes/
```

Then enable SDDM if you use it:

```bash
sudo systemctl enable sddm
```

If you do not use SDDM, you can ignore this step and just keep the theme files for later.

---

## 4) Make scripts executable

This config contains custom helper scripts in `~/.local/bin`.

Run:

```bash
chmod +x ~/.local/bin/*
```

If you want to be extra safe and only enable the ones used by this setup:

```bash
chmod +x ~/.local/bin/caffeine \
  ~/.local/bin/camera-toggle \
  ~/.local/bin/clipboard.sh \
  ~/.local/bin/select-wallpaper.sh
```

The key script here is `select-wallpaper.sh`, which is used for wallpaper switching.

---

## 5) Make sure the dotfiles are loaded

This config expects Zsh to be your default shell. If needed:

```bash
chsh -s /usr/bin/zsh
```

Then reload the shell:

```bash
source ~/.zshrc
```

If `starship` is not installed correctly, you may need to install it again:

```bash
starship init zsh
```

---

## 6) Install the cursor theme

The config uses the Bibata cursor theme:

```bash
sudo pacman -S bibata-cursor-theme
```

or AUR:

```bash
paru -S bibata-cursor-theme
```

This matches the setting in the Hyprland config:

- `XCURSOR_THEME=Bibata-Modern-Classic`
- `HYPRCURSOR_THEME=Bibata-Modern-Classic`

---

## 7) Make sure the wallpaper directory exists

The workspace includes wallpapers under:

```bash
~/Pictures/wallpapers
```

You can also set a wallpaper manually with:

```bash
~/.local/bin/select-wallpaper.sh /path/to/your/wallpaper.jpg
```

Example:

```bash
~/.local/bin/select-wallpaper.sh ~/Pictures/wallpapers/wll1.jpg
```

---

## 8) Enable the custom theme colors

This setup uses Matugen and color theme generation. The config references generated theme files in:

- `~/.config/colors.zsh`
- `~/.config/qt5ct/colors/colors.conf`
- `~/.config/qt6ct/colors/colors.conf`
- `~/.config/kitty/colors.conf`
- `~/.config/btop/themes/colors.theme`

If these files do not exist after copying, generate or re-run Matugen to create them.

---

## 9) Start Hyprland

After everything is copied, reboot or log out and log in to Hyprland.

You can also start it manually from a tty:

```bash
Hyprland
```

If the config has any problems, check with:

```bash
hyprctl reload
```

and inspect the Hyprland log if needed:

```bash
journalctl -b -u sddm
```

---

## 10) Useful notes about this rice

This setup is using:

- `hyprland.lua` as the main config entrypoint
- `quickshell` for the bar and widgets
- `hypridle` and `hyprlock` for idle and lock behavior
- `kitty` as the terminal
- `matugen` + `awww` for theme and wallpaper generation
- `fastfetch` for the terminal welcome screen
- `starship` for the prompt
- custom keybindings for launching apps, toggling UI panels, screenshots, and media controls

The main config files are in:

- `~/.config/hypr/`
- `~/.config/quickshell/`
- `~/.config/kitty/`
- `~/.config/zsh/`
- `~/.local/bin/`
- `~/.zshrc`

---

## 11) Quick install summary

If you want the shortest working setup flow, this is the order:

```bash
sudo pacman -S --needed hyprland hypridle hyprlock kitty zsh starship qt5ct qt6ct fzf fastfetch btop cava dolphin grim slurp wl-clipboard brightnessctl playerctl cliphist matugen awww neovim git networkmanager pipewire wireplumber pavucontrol xdg-desktop-portal-hyprland
paru -S quickshell librewolf codium vesktop bibata-cursor-theme zsh-autosuggestions zsh-syntax-highlighting
cp -a ./.config/. ~/.config/
cp -a ./.local/. ~/.local/
cp -a ./.zshrc ~/.zshrc
chmod +x ~/.local/bin/*
source ~/.zshrc
sudo cp -r ./usr/share/sddm/themes/kabu /usr/share/sddm/themes/
```

Then reboot or log into Hyprland.

---

## 12) Troubleshooting

If something does not launch:

```bash
which hyprland
which quickshell
which kitty
which starship
which awww
which matugen
```

If a command is missing, install it before starting Hyprland.

If the panel is broken, check if Quickshell is installed and running:

```bash
qs --help
```

If the theme is not applying, regenerate the config files and reload:

```bash
hyprctl reload
```

---

This setup should work well as a clean Hyprland rice on Arch Linux. If you want, I can also make a second README in a more “copy-paste from terminal” format for one-command installation.
