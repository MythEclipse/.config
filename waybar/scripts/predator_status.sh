#!/bin/bash
PROFILE_PATH="/sys/firmware/acpi/platform_profile"
CURRENT=$(cat $PROFILE_PATH 2>/dev/null)
case $CURRENT in
    low-power)
        ICON="🔋"
        TEXT="Eco"
        ;;
    quiet)
        ICON="🍃"
        TEXT="Quiet"
        ;;
    balanced)
        ICON="⚖️"
        TEXT="Balanced"
        ;;
    balanced-performance)
        ICON="⚡"
        TEXT="Dynamic"
        ;;
    performance)
        ICON="🔥"
        TEXT="Turbo"
        ;;
    *)
        ICON="❓"
        TEXT="Unknown"
        ;;
esac
echo "{\"text\": \"$ICON $TEXT\", \"tooltip\": \"Current Mode: $TEXT\", \"class\": \"$CURRENT\"}"
