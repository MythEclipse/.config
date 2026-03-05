#!/usr/bin/env python3
import json
import urllib.request
import urllib.parse
import os
import time

CACHE_FILE = "/tmp/waybar_weather_cache.json"
CACHE_TIMEOUT = 900 # 15 minutes

def get_weather():
    # Check cache
    if os.path.exists(CACHE_FILE):
        file_age = time.time() - os.path.getmtime(CACHE_FILE)
        if file_age < CACHE_TIMEOUT:
            try:
                with open(CACHE_FILE, 'r') as f:
                    return json.load(f)
            except:
                pass

    try:
        # wttr.in format=j1 gives JSON
        url = "https://wttr.in/?format=j1"
        req = urllib.request.Request(url, headers={'User-Agent': 'curl'})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            
            current = data['current_condition'][0]
            temp_C = current['temp_C']
            desc_val = current['weatherDesc'][0]['value']
            
            # Simple icon mapping based on desc
            icon = "" # default cloud
            desc = desc_val.lower()
            if "sunny" in desc or "clear" in desc: icon = ""
            elif "rain" in desc or "shower" in desc: icon = ""
            elif "snow" in desc: icon = ""
            elif "fog" in desc or "mist" in desc: icon = ""
            elif "thunder" in desc: icon = ""
            
            output = {
                "text": f"{icon} {temp_C}°C",
                "tooltip": f"<b>{desc_val}</b>\nFeels like: {current['FeelsLikeC']}°C\nWind: {current['windspeedKmph']}km/h\nHumidity: {current['humidity']}%",
                "class": "normal",
                "alt": desc_val
            }
            
            # Save cache
            with open(CACHE_FILE, 'w') as f:
                json.dump(output, f)
            
            return output
            
    except Exception as e:
        # Return error/cached stale if valid
        return {"text": "", "tooltip": str(e), "class": "error", "alt": "error"}

def main():
    print(json.dumps(get_weather()))

if __name__ == "__main__":
    main()
