#!/bin/bash

# Configuration
THRESHOLD=20
BATTERY_PATH="/sys/class/power_supply/BAT1"
CHECK_INTERVAL=60 # seconds

while true; do
    if [ -d "$BATTERY_PATH" ]; then
        CAPACITY=$(cat "$BATTERY_PATH/capacity")
        STATUS=$(cat "$BATTERY_PATH/status")

        if [ "$CAPACITY" -le "$THRESHOLD" ] && [ "$STATUS" != "Charging" ] && [ "$STATUS" != "Full" ]; then
            notify-send -u critical "Terminal Battery Power" "Battery level is ${CAPACITY}%. The system will SHUT DOWN in 60 seconds."
            
            # Wait for grace period
            sleep 60
            
            # Re-check battery status before final shutdown
            CAPACITY=$(cat "$BATTERY_PATH/capacity")
            STATUS=$(cat "$BATTERY_PATH/status")
            
            if [ "$CAPACITY" -le "$THRESHOLD" ] && [ "$STATUS" != "Charging" ] && [ "$STATUS" != "Full" ]; then
                notify-send -u critical "System Shutdown" "Executing immediate poweroff due to critical battery level."
                systemctl poweroff
            else
                notify-send "Shutdown Cancelled" "Power source detected or battery level increased."
            fi
        fi
    fi
    sleep "$CHECK_INTERVAL"
done
