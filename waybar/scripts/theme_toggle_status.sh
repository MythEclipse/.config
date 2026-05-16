#!/usr/bin/env bash
# theme_toggle_status.sh — output JSON untuk custom/theme-toggle waybar module

SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)

if [[ "$SCHEME" == *"dark"* ]]; then
    echo '{"text": "", "alt": "dark", "tooltip": "Dark Mode — klik untuk Light", "class": "dark"}'
else
    echo '{"text": "", "alt": "light", "tooltip": "Light Mode — klik untuk Dark", "class": "light"}'
fi
