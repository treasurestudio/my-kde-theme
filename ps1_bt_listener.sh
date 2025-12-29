#!/bin/bash

# --- CONFIGURATION ---
HEAVYS="bluez_output.A8_99_DC_54_85_AC.1"
# Fallback to default system output for the Sparta yell
SPEAKERS="@DEFAULT_SINK@" 
FLAG="/tmp/heavys_active"
PS1_SOUND="/home/john/Music/ps1_boot.wav"
SPARTA_SOUND="/home/john/Music/this_is_sparta.wav"

# --- THE LISTENER ---
pactl subscribe | while read -r line; do
    
    # 1. HANDLE CONNECTION (PS1 Sound)
    # Triggers when a new audio device is added
    if echo "$line" | grep -q "Event 'new' on sink"; then
        # Check if the new device is actually your Heavys
        if pactl list short sinks | grep -q "$HEAVYS"; then
            # Only play if we aren't already connected (stops volume bar noise)
            if [ ! -f "$FLAG" ]; then
                sleep 2.5
                paplay --device="$HEAVYS" "$PS1_SOUND"
                touch "$FLAG"
            fi
        fi

    # 2. HANDLE DISCONNECTION (Sparta Sound)
    # Triggers when a device is removed
    elif echo "$line" | grep -q "Event 'remove' on sink"; then
        # If the Heavys are no longer in the list
        if ! pactl list short sinks | grep -q "$HEAVYS"; then
            # If we were previously connected
            if [ -f "$FLAG" ]; then
                # Play Sparta through the default system speakers
                paplay --device="$SPEAKERS" "$SPARTA_SOUND"
                rm "$FLAG"
            fi
        fi
    fi
done
