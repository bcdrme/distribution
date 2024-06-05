#!/bin/sh

# Video output and device names recogized by xrandr/sysfs
internal="DSI-1"         # change as needed
external="HDMI-A-1"      # change as needed
device="card0-HDMI-A-1"  # change as needed

# If external display is connected, turn external display on
# and turn internal display off.
if [ $(cat /sys/class/drm/${device}/status) == "connected" ];
then 
    systemctl stop essway.service                      # stop essway service
    swaymsg output "${internal}" disable               # turn internal display off
    swaymsg output "${external}" resolution 1920x1080  # set resolution
    swaymsg output "${external}" enable                # turn external display on
    systemctl start essway.service

# If external display was just physically disconnected, turn 
# external display off and turn internal display on.
elif [ $(cat /sys/class/drm/${device}/status) == "disconnected" ];
then
    systemctl stop essway.service                      # stop essway service
    swaymsg output "${external}" disable                # turn external display off
    swaymsg output "${internal}" enable                 # turn internal display on
    systemctl start essway.service
else  # Do nothing if device status is unreadable
    exit
fi
