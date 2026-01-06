#!/bin/bash
# Title: Add SSID File
# Description: Adds SSIDs in a designated file to the SSID Pool. List must be located in /root/loot/pools/. SSIDs in file must be in a list.
# Author: Skinny
# Version: 1.0

POOLPATH="/root/loot/pools"

# Searches for the latest modified pool and puts filename in as default filename to upload
DEFAULTFILE=$(ls -t "$POOLPATH"/ 2>/dev/null | head -n 1)
FILENAME="$(TEXT_PICKER "Name of the Pool file." "$DEFAULTFILE")"

FULLPATH="$POOLPATH/$FILENAME"

# Checks to see if file to upload is present
if [ ! -f "$FULLPATH" ]; then
  LOG "File not found: $FILENAME"
  exit 1
fi

LOG " "
LOG "File Found. Uploading Pool"

# Read each line of the file and ingest into the PineAP SSID Pool
while IFS= read -r line; do
  printf '%s\n' "$line"
  PINEAPPLE_SSID_POOL_ADD "$line"
  LOG "$line"
done < "$FULLPATH"
