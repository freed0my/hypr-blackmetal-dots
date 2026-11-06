#!/usr/bin/env bash

# current state
cur=$(hyprctl monitors | grep -A15 "DP-1" | grep -m1 "transform:" | awk '{print $2}')

if [ "$cur" = "0" ]; then
  # flip
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })'
  hyprctl eval 'hl.monitor({ output = "DP-1", mode = "1920x1080@240", position = "1920x0", scale = 1, transform = 2 })'
else
  # restore
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })'
  hyprctl eval 'hl.monitor({ output = "DP-1", mode = "1920x1080@240", position = "1920x0", scale = 1, transform = 0 })'
fi
