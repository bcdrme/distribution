#!/bin/bash

systemctl stop essway.service

swaymsg output HDMI-A-1 resolution 1920x1080
swaymsg output HDMI-A-1 toggle
swaymsg output DSI-1 toggle

systemctl start essway.service