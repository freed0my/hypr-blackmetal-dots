#!/usr/bin/env bash

# current state
cur=$(hyprctl monitors | grep -A5 "DP-1" | grep "transform:" | awk '{print $2}')

if [ "$cur" = "0" ]; then
  # flip
  hyprctl keyword monitor "HDMI-A-1, 1920x1080@60, 0x0, 1"
  hyprctl keyword monitor "DP-1, 1920x1080@240, 1920x0, 1, transform, 2"
else
  # restore
  hyprctl keyword monitor "HDMI-A-1, 1920x1080@60, 0x0, 1"
  hyprctl keyword monitor "DP-1, 1920x1080@240, 1920x0, 1, transform, 0"
fi
