#!/bin/sh
# Title: wpa_handshake_quality_check
# Description: Fast WPA handshake quality analysis with duplicate detection
# Author: benwies
# Version: 1.0
# Category: reconnaissance/sniffing

# Options
HANDSHAKE_DIR="/mmc/root/loot/handshakes"
OUTPUT_BASE="/mmc/root/loot/handshakes_sorted"
HASH_DB="/mmc/root/loot/handshakes_sorted/handshake_hashes.db"

# INIT
LED MAGENTA
LOG "WPA Handshake Quality Check started"

mkdir -p "$OUTPUT_BASE/VALID_FULL" "$OUTPUT_BASE/PARTIAL" "$OUTPUT_BASE/INVALID"
[ -f "$HASH_DB" ] || touch "$HASH_DB"

set -- "$HANDSHAKE_DIR"/*.pcap
[ -e "$1" ] || {
  LOG "No handshake PCAP files found"
  LED BLUE
  LED WHITE
  exit 0
}

PCAPS="$@"
PCAP_COUNT=$#


LOG "Found $PCAP_COUNT handshake files"

INDEX=1
PROCESSED=0
SKIPPED=0

for PCAP in $PCAPS; do
  BASENAME=$(basename "$PCAP")

  # Check for duplicates
  HASH=$(md5sum "$PCAP" | awk '{print $1}')

  if grep -qx "$HASH" "$HASH_DB"; then
    LOG "[$INDEX/$PCAP_COUNT] Skipping duplicate: $BASENAME"
    SKIPPED=$((SKIPPED + 1))
    INDEX=$((INDEX + 1))
    continue
  fi

  LOG "[$INDEX/$PCAP_COUNT] Processing $BASENAME"

  # SSID best-effort
  SSID=$(strings "$PCAP" | grep -m1 -E '^[[:print:]]{3,32}$')
  [ -z "$SSID" ] && SSID="UNKNOWN_SSID"
  SSID_CLEAN=$(echo "$SSID" | tr ' ' '_' | tr -cd 'A-Za-z0-9_')

  # Fast EAPOL detection
  EAPOL_COUNT=$(tcpdump -nn -r "$PCAP" -c 4 ether proto 0x888e 2>/dev/null | wc -l)

  if [ "$EAPOL_COUNT" -ge 4 ]; then
    QUALITY="VALID_FULL"
    DEST="$OUTPUT_BASE/VALID_FULL"
    LED GREEN
  elif [ "$EAPOL_COUNT" -gt 0 ]; then
    QUALITY="PARTIAL"
    DEST="$OUTPUT_BASE/PARTIAL"
    LED AMBER
  else
    QUALITY="INVALID"
    DEST="$OUTPUT_BASE/INVALID"
    LED RED
  fi

  NEW_NAME="${SSID_CLEAN}__${QUALITY}__EAPOL${EAPOL_COUNT}__$(date +%Y%m%d_%H%M%S).pcap"

  if ! cp "$PCAP" "$DEST/$NEW_NAME"; then
    LOG "[$SSID] Failed to copy $BASENAME → $DEST"
    LED RED
    INDEX=$((INDEX + 1))
    continue
  fi

  echo "$HASH" >> "$HASH_DB"
  PROCESSED=$((PROCESSED + 1))

  LOG "[$SSID] $BASENAME → $QUALITY (EAPOL=$EAPOL_COUNT)"

  INDEX=$((INDEX + 1))
done

# Summary
LOG "Processing completed"
LOG "New handshakes processed: $PROCESSED"
LOG "Duplicates skipped: $SKIPPED"

LED WHITE

ALERT "WPA Handshake Quality Check complete.

Files organized into:
$OUTPUT_BASE

VALID_FULL / PARTIAL / INVALID"

exit 0
