#!/bin/bash

while true; do
    MENU=""

    while IFS= read -r line; do
        ID="${line%%|*}"
        NAME="${line#*|}"

        VOL=$(pactl get-sink-input-volume "$ID" 2>/dev/null |
            grep -oE '[0-9]+%' | head -n1 | tr -d '%')

        MUTED=$(pactl get-sink-input-mute "$ID" 2>/dev/null | awk '{print $2}')

        [ -z "$VOL" ] && continue

        if [ "$MUTED" = "yes" ]; then
            ICON="󰝟"
        else
            ICON="󰕾"
        fi

        MENU+="$ID|$ICON  $NAME    $VOL%"$'\n'
    done < <(
        pactl list sink-inputs |
        awk '
            /^Sink Input #/ {
                id=$3
                gsub("#","",id)
            }

            /application.name =/ {
                name=$0
                sub(/^.*application.name = "/,"",name)
                sub(/"$/,"",name)

                if (id != "" && name != "")
                    print id "|" name
            }
        '
    )

    # If no apps are playing audio
    if [ -z "$MENU" ]; then
        printf '%s\n' "󰝟  No active audio streams" |
            wofi --dmenu \
                 --prompt "Audio" \
                 --width 420 \
                 --height 100 \
                 --cache-file /dev/null

        exit 0
    fi

    CHOICE=$(printf '%s' "$MENU" |
        wofi --dmenu \
             --prompt "Audio" \
             --width 420 \
             --height 300 \
             --cache-file /dev/null)

    [ -z "$CHOICE" ] && exit 0

    ID="${CHOICE%%|*}"
    LABEL="${CHOICE#*|}"

    CURRENT=$(pactl get-sink-input-volume "$ID" |
        grep -oE '[0-9]+%' | head -n1 | tr -d '%')

    ACTION=$(printf '%s\n' \
        "󰕾  ${CURRENT}%" \
        " " \
        "󰝟  −10%" \
        "󰝟  −5%" \
        "󰕾  +5%" \
        "󰕾  +10%" \
        "󰖁  Mute" |
        wofi --dmenu \
             --prompt "$LABEL" \
             --width 300 \
             --height 250 \
             --cache-file /dev/null)

    case "$ACTION" in
        *"−10%"*) pactl set-sink-input-volume "$ID" -10% ;;
        *"−5%"*)  pactl set-sink-input-volume "$ID" -5% ;;
        *"+5%"*)  pactl set-sink-input-volume "$ID" +5% ;;
        *"+10%"*) pactl set-sink-input-volume "$ID" +10% ;;
        *"Mute"*) pactl set-sink-input-mute "$ID" toggle ;;
    esac
done
