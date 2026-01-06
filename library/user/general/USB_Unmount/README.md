# USB Safe Unmount (WiFi Pineapple PAGER)

## Overview
This payload safely unmounts a USB storage device mounted at `/mnt/usb` on the WiFi Pineapple PAGER.

It is intended to be run **after an engagement or data collection session** to ensure that all buffered writes are flushed and the USB device can be safely removed without risk of file corruption or data loss.

This payload does **not** modify any system configuration or static variables.

---

## Intended Use
- Safely remove USB flash storage after logging loot or evidence
- Prevent corrupted CSV, PCAP, or log files
- Support forensic-safe handling of collected data

---

## What This Payload Does
1. Verifies that `/mnt/usb` exists
2. Verifies that `/mnt/usb` is currently mounted
3. Prompts the user for confirmation before unmounting
4. Flushes all pending filesystem writes using `sync`
5. Cleanly unmounts the USB device using `umount`
6. Logs success or provides a clear error message if the device is busy

---

## What This Payload Does NOT Do
- Does NOT modify `/etc/fstab`
- Does NOT change or export environment variables
- Does NOT delete or move any data
- Does NOT force unmount (no lazy or forced unmounts)

---

## Requirements
- USB storage mounted at `/mnt/usb`
- Payloads or processes writing to the USB must be stopped prior to running
- Uses standard Pager UI primitives:
  - `LOG`
  - `ERROR_DIALOG`
  - `TEXT_PICKER`

---

## Operator Notes
- Always stop any payloads that may be writing to USB before running this
- If unmount fails with “device busy”, wait a few seconds and retry
- Only remove the USB device after the payload confirms successful unmount

---

## Testing
Tested on WiFi Pineapple PAGER using:
- USB flash storage (ext4 / exFAT / FAT32)
- Manual loot creation under `/mnt/usb`
- Repeated mount/unmount cycles

---

## License / Attribution
Authored by Stuffy24.  
No third-party code included.
