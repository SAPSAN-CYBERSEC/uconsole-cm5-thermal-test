#!/bin/bash
# Periodic screenshots during a test phase (Wayland / labwc, uses grim).
# Usage: ./screenshot-loop.sh <phase> <duration_s> [interval_s]
export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0
PHASE="${1:-run}"; DUR="${2:-600}"; INT="${3:-60}"
mkdir -p ~/thermal-shots
END=$(( $(date +%s) + DUR ))
while [ "$(date +%s)" -lt "$END" ]; do
    T=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/temp)
    grim ~/thermal-shots/${PHASE}-$(date +%H%M%S)-${T}C.png 2>/dev/null
    sleep "$INT"
done
