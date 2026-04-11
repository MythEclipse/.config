#!/bin/bash
PROFILE_PATH="/sys/firmware/acpi/platform_profile"
CURRENT=$(cat $PROFILE_PATH 2>/dev/null)
case $CURRENT in
    quiet)
        ICON="🍃"
        TEXT="Silent"
        ;;
    balanced)
        ICON="⚖️"
        TEXT="Balanced"
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

