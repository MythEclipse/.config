#!/usr/bin/env python3
import json
import urllib.request
import os
import time
from datetime import datetime

CACHE_FILE = "/tmp/waybar_weather_v2_cache.json"
CACHE_TIMEOUT = 900  # 15 minutes

# WMO Weather interpretation codes (WW)
# https://open-meteo.com/en/docs
WMO_ICONS = {
    0: "",  # Clear sky
    1: "",  # Mainly clear
    2: "",  # Partly cloudy
    3: "",  # Overcast
    45: "", # Fog
    48: "", # Depositing rime fog
    51: "", # Drizzle: Light
    53: "", # Drizzle: Moderate
    55: "", # Drizzle: Dense
    56: "", # Freezing Drizzle: Light
    57: "", # Freezing Drizzle: Dense
    61: "", # Rain: Slight
    63: "", # Rain: Moderate
    65: "", # Rain: Heavy
    66: "", # Freezing Rain: Light
    67: "", # Freezing Rain: Heavy
    71: "", # Snow fall: Slight
    73: "", # Snow fall: Moderate
    75: "", # Snow fall: Heavy
    77: "", # Snow grains
    80: "", # Rain showers: Slight
    81: "", # Rain showers: Moderate
    82: "", # Rain showers: Violent
    85: "", # Snow showers slight
    86: "", # Snow showers heavy
    95: "", # Thunderstorm: Slight or moderate
    96: "", # Thunderstorm with slight hail
    99: "", # Thunderstorm with heavy hail
}

def get_location():
    try:
        with urllib.request.urlopen("http://ip-api.com/json") as url:
            data = json.loads(url.read().decode())
            return data['lat'], data['lon'], data['city']
    except:
        return None, None, "Unknown"

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
        lat, lon, city = get_location()
        if not lat:
            return {"text": "ERR", "tooltip": "Could not locate", "class": "error"}

        # Fetch from OpenMeteo
        api_url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto"
        
        req = urllib.request.Request(api_url, headers={'User-Agent': 'Waybar-Script'})
        with urllib.request.urlopen(req) as url:
            data = json.loads(url.read().decode())
            
            current = data['current']
            daily = data['daily']
            
            temp = current['temperature_2m']
            code = current['weather_code']
            icon = WMO_ICONS.get(code, "")
            
            # Build tooltip with forecast
            tooltip = f"<b>{city}</b>\n\n"
            tooltip += f"Current: {temp}°C {icon}\n"
            tooltip += f"Humidity: {current.get('relative_humidity_2m', 'N/A')}%\n"
            tooltip += f"Wind: {current.get('wind_speed_10m', 'N/A')} km/h\n\n"
            tooltip += "<b>Forecast:</b>\n"
            
            for i in range(min(3, len(daily['time']))):
                day_date = daily['time'][i]
                max_t = daily['temperature_2m_max'][i]
                min_t = daily['temperature_2m_min'][i]
                d_code = daily['weather_code'][i]
                d_icon = WMO_ICONS.get(d_code, "")
                tooltip += f"{day_date}: {min_t}°C - {max_t}°C {d_icon}\n"

            output = {
                "text": f"{icon} {temp}°C",
                "tooltip": tooltip.strip(),
                "class": "weather",
                "alt": str(code)
            }
            
            # Save cache
            with open(CACHE_FILE, 'w') as f:
                json.dump(output, f)
                
            return output

    except Exception as e:
        return {"text": "", "tooltip": str(e), "class": "error"}

def main():
    print(json.dumps(get_weather()))

if __name__ == "__main__":
    main()
