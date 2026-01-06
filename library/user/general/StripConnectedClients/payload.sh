#!/bin/bash
# Title: Strip Connected Clients
# Description: Pulls previously connected clients from the recon database and stores that list in a file located in /root/loot/info.
# Author: Skinny
# Version: 1.0

INFOPATH="/root/loot/info"
RECONDB="/root/recon/recon.db"

# if info loot folder does not exist, then create it
LOG "Creating the info Loot Directory if it doesn't exist."
if [ ! -d "$INFOPATH" ]; then
  mkdir -p "$INFOPATH"
  LOG "Find your file in the newly created $INFOPATH."
else
  LOG "$INFOPATH exists already."
fi

# Prompts user for filename to dump clients. Default value includes data and time.
FILENAME="$(TEXT_PICKER "Enter a File Name." "Clients_$(date +%Y%m%d_%H%M%S).txt")"

LOG " "

# Run query via sqlite3
sqlite3 -cmd ".mode tabs" -cmd ".headers off" "$RECONDB" \
  "SELECT mac, ssid, connected_time FROM hostap_client;" |
while IFS=$'\t' read -r MAC SSID CONNECTED_TIME; do
  [ -z "$MAC" ] && continue

  VENDOR=$(whoismac -m "$MAC")

  # Output the fields to a file
  printf '%s, MAC:%s, SSID:%s, ConnectedTime:%s' "$VENDOR" "$MAC" "$SSID" "$CONNECTED_TIME" >> "$INFOPATH/$FILENAME"
  LOG "MAC: $MAC | Connected to: $SSID"
done

printf "\n" >> "$INFOPATH/$FILENAME"
LOG " "
ALERT "Clients have been stripped from Recon DB.\n To see the full results go to $INFOPATH/$FILENAME"
