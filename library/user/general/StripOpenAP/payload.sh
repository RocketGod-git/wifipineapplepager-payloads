#!/bin/bash
# Title: Strip Open APs from Recon
# Description: Strips open access points from the recon database and stores that list in a file located in /root/loot/pools.
# Author: Skinny
# Version: 1.0

POOLPATH="/root/loot/pools"

# if pools loot folder does not exist, then create it
LOG "Creating the Pool Loot Directory if it doesn't exist."
if [ ! -d "$POOLPATH" ]; then
  mkdir -p "$POOLPATH"
  LOG "Find your file in the newly created $POOLPATH."
else
  LOG "Remember, your file can be found in $POOLPATH."
fi

# Prompts user for filename to dump SSID pool. Default value includes data and time.
FILENAME="$(TEXT_PICKER "Enter a Pool Name." "pool_$(date +%Y%m%d_%H%M%S).txt")"

# create a temp file to dump database contents and extract only entries with no encryption
sqlite3 /root/recon/recon.db "SELECT * FROM ssid WHERE encryption=0;" > ./aps.dump 2>/dev/null


# format the dump file to only contain a unique sorted list
awk -F'|' 'length($6) > 0 && !seen[$6]++ { print $6 }' aps.dump | sort  > "$POOLPATH/$FILENAME"

# erase the temp dump file
rm aps.dump

LOG " "
LOG " "
LOG "Open APs have been stripped from Recon DB."
