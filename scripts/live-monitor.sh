#!/bin/bash
# On-screen live readout of the values the logger records.
# Run it in a terminal window on the device so screenshots carry the numbers.
while true; do
  T=$(awk '{printf "%.1f", $1/1000}' /sys/class/thermal/thermal_zone0/temp)
  F=$(vcgencmd measure_clock arm | cut -d= -f2); F=$((F/1000000))
  TH=$(vcgencmd get_throttled | cut -d= -f2)
  V=$(vcgencmd measure_volts core | cut -d= -f2)
  B=$(cat /sys/class/power_supply/axp20x-battery/capacity)
  L=$(cut -d' ' -f1 /proc/loadavg)
  clear
  echo "  uConsole CM5 thermal test - stock case"
  echo "  ========================================"
  printf "   SoC TEMP     : %s C\n" "$T"
  printf "   ARM CLOCK    : %s MHz\n" "$F"
  printf "   CORE VOLTAGE : %s\n" "$V"
  printf "   THROTTLED    : %s\n" "$TH"
  printf "   LOAD AVG     : %s\n" "$L"
  printf "   BATTERY      : %s%%\n" "$B"
  printf "   TIME         : %s\n" "$(date '+%H:%M:%S')"
  sleep 2
done
