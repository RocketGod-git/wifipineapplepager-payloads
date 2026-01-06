#!/bin/bash
# Title: live_walk
# Description: A WiFi logger that records networks in detail as you walk or perform audits . 
# Author: MusicalVR

LOOTDIR="/root/loot/live_walk"
mkdir -p "$LOOTDIR"
IFACE="wlan1mon"
PREFIX="walk_$(date +%H%M)"
FULL_PATH="$LOOTDIR/$PREFIX-01.csv"

# Log systems
cleanup() {
    LOG "!!!"
    LOG "Stopping Capture..."
    kill "$PID" 2>/dev/null
    killall airodump-ng > /dev/null 2>&1
    LOG "Saved: $PREFIX"
    exit 0
}

# Startup
killall -9 airodump-ng > /dev/null 2>&1
killall -9 pineapd > /dev/null 2>&1
VIBRATE 50 100
LED B 100
LOG "Live Walk Started..."
LOG "To exit: Back out and logs will be auto saved from the last capture"
LOG "Loot Location: $LOOTDIR"
LOG "Once the 'Loot size' starts displaying a numbers, the capure is alive"

# Launch in background
cd "$LOOTDIR" || exit
airodump-ng --output-format csv -w "$PREFIX" "$IFACE" > /dev/null 2>&1 &
PID=$!

# --- The Status Loop ---
while kill -0 "$PID" 2>/dev/null; do
    SIZE=$(du -h "$FULL_PATH" 2>/dev/null | cut -f1)
    LOG "Active | Loot size: $SIZE"
    sleep 30
done
