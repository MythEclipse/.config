#!/usr/bin/env python3
import json
import subprocess
import sys
import html

def get_player_metadata():
    try:
        # Check if any player is running
        status = subprocess.check_output(["playerctl", "status"], stderr=subprocess.DEVNULL).decode().strip()
        if not status:
            return None
        
        # Get metadata
        artist = subprocess.check_output(["playerctl", "metadata", "artist"], stderr=subprocess.DEVNULL).decode().strip()
        title = subprocess.check_output(["playerctl", "metadata", "title"], stderr=subprocess.DEVNULL).decode().strip()
        album = subprocess.check_output(["playerctl", "metadata", "album"], stderr=subprocess.DEVNULL).decode().strip()
        player_name = subprocess.check_output(["playerctl", "metadata", "--format", "{{playerName}}"], stderr=subprocess.DEVNULL).decode().strip()
        
        return {
            "status": status,
            "artist": html.escape(artist),
            "title": html.escape(title),
            "album": html.escape(album),
            "player_name": player_name
        }
    except subprocess.CalledProcessError:
        return None
    except Exception as e:
        return None

def main():
    data = get_player_metadata()
    
    if not data:
        print(json.dumps({"text": "", "alt": "stopped", "tooltip": "No Media Playing", "class": "stopped"}))
        return

    icon_map = {
        "spotify": "",
        "firefox": "",
        "mpv": "",
        "chromium": "",
        "default": ""
    }
    
    icon = icon_map.get(data["player_name"], icon_map["default"])
    text = f"{icon}  {data['artist']} - {data['title']}"
    
    # Truncate if too long
    if len(text) > 50:
        text = text[:47] + "..."
        
    tooltip = f"<b>{data['player_name'].capitalize()}</b>\n" \
              f"Title: {data['title']}\n" \
              f"Artist: {data['artist']}\n" \
              f"Album: {data['album']}\n" \
              f"Status: {data['status']}"

    css_class = data["status"].lower()
    
    output = {
        "text": text,
        "alt": data["status"],
        "tooltip": tooltip,
        "class": css_class
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()
