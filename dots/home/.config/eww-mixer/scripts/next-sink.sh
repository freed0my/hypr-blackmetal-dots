#!/bin/bash
# Switches audio output to the next device.
mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')
cur=$(pactl get-default-sink)
for i in "${!sinks[@]}"; do
    if [ "${sinks[$i]}" = "$cur" ]; then
        pactl set-default-sink "${sinks[$(( (i + 1) % ${#sinks[@]} ))]}"
        exit
    fi
done
