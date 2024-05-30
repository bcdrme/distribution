#!/bin/bash

# File to store the previous state of connected monitors
PREV_MONITORS_FILE="/tmp/prev_monitors"

# Get the current state of connected monitors
CURRENT_MONITORS=$(swaymsg -t get_outputs | grep -oP '(?<=name":")[^"]+' | sort)

# Check if the previous state file exists
if [ -f "$PREV_MONITORS_FILE" ]; then
    # Read the previous state of connected monitors
    PREV_MONITORS=$(cat "$PREV_MONITORS_FILE")
    
    # Find new monitors
    NEW_MONITORS=$(comm -13 <(echo "$PREV_MONITORS") <(echo "$CURRENT_MONITORS"))
    
    if [ -n "$NEW_MONITORS" ]; then
        # Execute your commands for new monitor(s)
        echo "New monitor(s) connected: $NEW_MONITORS" > /tmp/monitor-plug.log

        # Example command: adjust display settings for the new monitor(s)
        for monitor in $NEW_MONITORS; do
            swaymsg output "$monitor" enable
        done
    fi
fi

# Save the current state of connected monitors for future comparison
echo "$CURRENT_MONITORS" > "$PREV_MONITORS_FILE"


systemctl stop essway.service

swaymsg output HDMI-A-1 resolution 1920x1080
swaymsg output HDMI-A-1 toggle
swaymsg output DSI-1 toggle

systemctl start essway.service