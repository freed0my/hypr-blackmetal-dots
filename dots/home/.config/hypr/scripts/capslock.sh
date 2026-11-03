#!/bin/sh
# prints a warning when Caps Lock is on (for hyprlock)
for f in /sys/class/leds/*capslock/brightness; do
    [ "$(cat "$f" 2>/dev/null)" = "1" ] && { printf '\U000f0232  caps lock'; exit 0; }
done
echo ""
