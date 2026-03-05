#!/bin/bash
killall waybar
waybar & disown
echo "Waybar reloaded!"
