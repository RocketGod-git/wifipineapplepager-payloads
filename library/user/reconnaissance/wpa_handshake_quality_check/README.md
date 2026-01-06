# WPA Handshake Quality Check

### v1.0

**Author:** [benwies](https://github.com/benwies)

**Category:** Reconnaissance

---

## What This Is

WPA Handshake Quality Check is a passive post-processing payload for the WiFi Pineapple Pager that analyzes captured WPA handshake PCAP files and determines whether they are actually usable.

Instead of blindly collecting large numbers of cryptically named capture files, this payload evaluates each handshake, classifies its quality, and organizes the results into clear, human-readable categories.

It is designed to run fully offline and does not capture, transmit, or modify network traffic.

---

## What It Does

This payload performs the following actions:

- Scans existing `.pcap` files in the handshake loot directory  
- Detects WPA EAPOL frames using a Pager-compatible method  
- Classifies each capture into:
  - **VALID_FULL** (complete 4-way handshake)
  - **PARTIAL** (incomplete handshake)
  - **INVALID** (no usable handshake data)
- Renames and copies files into structured output directories  
- Prevents duplicate processing using hash-based detection  
- Logs live progress and results to the Pager UI  

Original capture files are never modified or deleted.

---

## Why This Exists

Handshake capture tools often generate large numbers of files with names based on MAC addresses and timestamps. Over time this leads to:

- Duplicate captures  
- Unusable handshakes mixed with valid ones  
- No clear indication which files are worth keeping  

This payload solves that by turning raw captures into an organized reconnaissance dataset that can be reviewed quickly and confidently.

---

## Classification Logic

The payload uses EAPOL frame detection to determine handshake quality:

- **VALID_FULL**
  - At least 4 EAPOL frames detected
- **PARTIAL**
  - 1–3 EAPOL frames detected
- **INVALID**
  - No EAPOL frames detected

For performance reasons, detection stops once the minimum required information has been gathered.

---

## Output Structure

```
/mmc/root/loot/handshakes_sorted/
├── VALID_FULL/
├── PARTIAL/
└── INVALID/
```

Example filename:

```
OfficeWiFi__VALID_FULL__EAPOL4__20251228_224512.pcap
```

---

## Duplicate Handling

To avoid processing the same handshake multiple times, the payload uses a hash database:

```
/mmc/root/loot/handshakes_sorted/handshake_hashes.db
```

- Each processed PCAP is hashed
- Previously seen handshakes are skipped on subsequent runs
- The database can be deleted at any time to force a full rescan

This ensures repeat executions remain fast and storage stays clean.

---

## Requirements

- Existing WPA handshake PCAP files  
- `tcpdump` (available by default on the Pager)  
- No internet connection required  

---
