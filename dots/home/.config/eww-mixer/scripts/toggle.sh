#!/bin/bash
# Opens/closes the mixer. eww runs without ~/.config/gtk-3.0/gtk.css
# so the global GTK theme (Thunar) doesn't override the mixer style.
XDG_CONFIG_HOME="$HOME/.config/eww-mixer/gtk-isolated" \
    eww -c "$HOME/.config/eww-mixer" open --toggle mixer
