#!/usr/bin/env python3
import gi
import json
import sys
import html

gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

def on_metadata(player, metadata, manager):
    update_output(player)

def on_play(player, status, manager):
    update_output(player)

def on_pause(player, status, manager):
    update_output(player)

def update_output(player):
    if not player or player.props.status == "Stopped":
        print(json.dumps({"text": "", "alt": "stopped", "tooltip": "", "class": "stopped"}), flush=True)
        return

    try:
        # Get metadata
        title = player.get_title()
        artist = player.get_artist()
        album = player.get_album()
        status = player.props.status
        player_name = player.props.player_name

        # Icons
        icon_map = {
            "spotify": "",
            "firefox": "", 
            "mpv": "",
            "chromium": "",
            "default": ""
        }
        icon = icon_map.get(player_name, icon_map["default"])
        
        # Text
        text = f"{artist} - {title}"
        if len(text) > 40:
            text = text[:37] + "..."
            
        # Tooltip
        tooltip = f"<b>{player_name.capitalize()}</b>\n" \
                  f"Title: {title}\n" \
                  f"Artist: {artist}\n" \
                  f"Album: {album}\n" \
                  f"Status: {status}"

        # CSS Class
        css_class = status.lower()
        if status == "Playing":
            alt = "playing"
        else:
            alt = "paused"

        output = {
            "text": html.escape(text),
            "alt": alt,
            "tooltip": tooltip,
            "class": css_class
        }
        print(json.dumps(output), flush=True)

    except Exception:
        # Fallback for transient errors
        pass

def on_player_vanished(manager, player):
    print(json.dumps({"text": "", "alt": "stopped", "class": "stopped"}), flush=True)

def init():
    manager = Playerctl.PlayerManager()
    
    def on_name_appeared(manager, name):
        init_player(name)

    def init_player(name):
        player = Playerctl.Player.new_from_name(name)
        player.connect('playback-status', on_play, manager)
        player.connect('metadata', on_metadata, manager)
        manager.manage_player(player)
        update_output(player)

    manager.connect('name-appeared', on_name_appeared)
    manager.connect('player-vanished', on_player_vanished)

    # Initial scan
    for name in manager.props.player_names:
        init_player(name)
        
    loop = GLib.MainLoop()
    loop.run()

if __name__ == "__main__":
    try:
        init()
    except KeyboardInterrupt:
        pass
