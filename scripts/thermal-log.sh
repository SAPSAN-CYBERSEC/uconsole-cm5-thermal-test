#!/bin/bash
# Logger termiczny uConsole CM5 - próbka co 5 s do CSV.
# Użycie: ./thermal-log.sh <nazwa-fazy> <czas-w-sekundach>
#   ./thermal-log.sh idle 600
#   ./thermal-log.sh stress 1800
#   ./thermal-log.sh cooldown 900
set -u
PHASE="${1:-run}"; DUR="${2:-600}"; INT=5
OUT="$HOME/thermal-${PHASE}-$(date +%Y%m%d-%H%M%S).csv"
echo "t_s,phase,temp_c,arm_hz,core_v,throttled,load1,batt_pct,batt_uv" > "$OUT"
END=$(( $(date +%s) + DUR )); T0=$(date +%s)
while [ "$(date +%s)" -lt "$END" ]; do
    NOW=$(date +%s)
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
    TEMP=$(awk -v t="$TEMP" 'BEGIN{printf "%.1f", t/1000}')
    ARM=$(vcgencmd measure_clock arm 2>/dev/null | cut -d= -f2 || echo 0)
    VOLT=$(vcgencmd measure_volts core 2>/dev/null | cut -d= -f2 | tr -d 'V' || echo 0)
    THR=$(vcgencmd get_throttled 2>/dev/null | cut -d= -f2 || echo NA)
    LOAD=$(cut -d' ' -f1 /proc/loadavg)
    BP=$(cat /sys/class/power_supply/*/capacity 2>/dev/null | head -1 || echo NA)
    BV=$(cat /sys/class/power_supply/*/voltage_now 2>/dev/null | head -1 || echo NA)
    echo "$((NOW-T0)),$PHASE,$TEMP,$ARM,$VOLT,$THR,$LOAD,$BP,$BV" >> "$OUT"
    sleep "$INT"
done
echo "zapisane: $OUT"
