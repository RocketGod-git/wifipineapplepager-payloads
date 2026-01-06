#!/bin/bash
# Title: Deduplicate Handshakes
# Author: Unit981
# Description: Updated alerting on handshake capture, will check for duplicate handshakes for the AP MAC, and is currently set to drop the duplicate handshakes & associated PCAP's to keep things clean.
# Version: 1.0

#Setting directory & variables
HANDSHAKE_DIR="/root/loot/handshakes/"
PCAP="$_ALERT_HANDSHAKE_PCAP_PATH"

# Extract SSID from beacon frames
SSID=$(tcpdump -r "$PCAP" -e -I -s 256 \
  | sed -n 's/.*Beacon (\([^)]*\)).*/\1/p' \
  | head -n 1)

# Fallback if SSID not found
[ -n "$SSID" ] || SSID="UNKNOWN_SSID"

#Making sure MAC is searchable
mac_clean=$(printf "%s" "$_ALERT_HANDSHAKE_AP_MAC_ADDRESS" | sed 's/[[:space:]]//g')
mac_upper=${mac_clean^^}

#Count files containing MAC anywhere in filename
handshake_count=$(find "$HANDSHAKE_DIR" -type f -name "*${mac_upper}*.22000" 2>/dev/null | wc -l)
pcap_count=$(find "$HANDSHAKE_DIR" -type f -name "*${mac_upper}*.pcap" 2>/dev/null | wc -l)

# Check if any full handshake already exists for this AP MAC
existing_file=$(find "$HANDSHAKE_DIR" -type f -name "*${mac_upper}*handshake.22000" 2>/dev/null | head -n 1)

# Check for duplicates based on count
if [ "$handshake_count" -gt 1 ]; then
    ALERT "#@ HACK THE PLANET @# \n\n Handshake captured! \n Duplicate handshake detected for \n SSID: $SSID - MAC: $_ALERT_HANDSHAKE_AP_MAC_ADDRESS \n Total Handshakes: $handshake_count"
    # Comment lines 34-36 stop dropping duplicates automatically
    ALERT "#@ Deduplication is ACTIVE @# \n\n Dropping duplicate handshake & PCAP for: \n SSID: $SSID \n AP MAC Address: $_ALERT_HANDSHAKE_AP_MAC_ADDRESS"
    rm -rf "$_ALERT_HANDSHAKE_HASHCAT_PATH"
    rm -rf "$_ALERT_HANDSHAKE_PCAP_PATH"
else
    ALERT "#@ HACK THE PLANET @# \n\n New handshake captured for SSID: $SSID \n Access Point BSSID: $_ALERT_HANDSHAKE_AP_MAC_ADDRESS \n Captured from Client MAC: $_ALERT_HANDSHAKE_CLIENT_MAC_ADDRESS"
fi