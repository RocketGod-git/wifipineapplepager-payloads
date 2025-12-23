#!/bin/bash
# Title:                Traceroute
# Description:          Performs a traceroute to a target IP address or hostname and logs the results
# Author:               eflubacher
# Version:              1.0

# Options
LOOTDIR=/root/loot/traceroute

# Prompt user for target IP address or hostname
LOG "Launching traceroute..."
target=$(TEXT_PICKER "Enter target host" "8.8.8.8")
case $? in
    $DUCKYSCRIPT_CANCELLED)
        LOG "User cancelled"
        exit 1
        ;;
    $DUCKYSCRIPT_REJECTED)
        LOG "Dialog rejected"
        exit 1
        ;;
    $DUCKYSCRIPT_ERROR)
        LOG "An error occurred"
        exit 1
        ;;
esac

# Create loot destination if needed
mkdir -p $LOOTDIR
# Sanitize target for filename (replace invalid chars with underscores)
safe_target=$(echo "$target" | tr '/: ' '_')
lootfile=$LOOTDIR/$(date -Is)_$safe_target

LOG "Running traceroute to $target..."
LOG "Results will be saved to: $lootfile\n"

# Run traceroute and save to file, also log each line
traceroute -q 1 $target | tee $lootfile | tr '\n' '\0' | xargs -0 -n 1 LOG

LOG "\nTraceroute complete!"

