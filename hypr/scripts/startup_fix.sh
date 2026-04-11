#!/bin/bash
# Startup Fix (Monitor & Waybar Reset)
# Berguna untuk mengatasi masalah Waybar/Wallpaper tidak muncul setelah login karena monitor belum siap

sleep 1
hyprctl reload
killall waybar hyprpaper dunst
sleep 1
waybar &
hyprpaper &
dunst &

# Ensure Zapzap is running (sometimes fails on early exec-once)
if ! pgrep -x "zapzap" > /dev/null; then
    /usr/bin/zapzap --ozone-platform-hint=auto &
fi

# Force Apply Theme (Karena kadang ke-reset)
gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
hyprctl setcursor Bibata-Modern-Ice 24
