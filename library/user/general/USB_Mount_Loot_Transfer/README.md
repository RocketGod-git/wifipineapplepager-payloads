# USB Mount and Transfer Loot (WiFi Pineapple PAGER)

## Overview
This payload mounts a USB storage device and optionally copies all existing loot from the WiFi Pineapple PAGER to the USB device.

It is designed to be:
- **Non-invasive**
- **Operator-controlled**
- **Safe for evidence handling**

All transfers are **copy-only** — original loot remains on the device.

---

## Intended Use
- Export engagement loot to removable storage
- Preserve evidence prior to shutdown or travel
- Avoid filling internal flash storage
- Support clean post-engagement workflows

---

## What This Payload Does
1. Detects a connected USB storage device
2. Mounts the device to `/mnt/usb` if not already mounted
3. Confirms successful mount via payload logs
4. Prompts the user whether to transfer all loot
5. Requires a second confirmation before copying
6. Copies loot directories to a timestamped folder on USB
7. Writes a transfer manifest documenting the operation

---

## What This Payload Does NOT Do
- Does NOT modify `/etc/fstab`
- Does NOT change system or static variables
- Does NOT delete original loot
- Does NOT assume a specific engagement structure

---

## Loot Sources Copied
By default, this payload copies:
- `/root/loot`
- `/tmp/loot`

These paths can be adjusted in the payload if your environment stores loot elsewhere.

---

## USB Destination Structure
Loot is copied to: /mnt/usb/pager-engagements/loot_transfer_<timestamp>/

Each source directory is preserved as a subfolder, and a `manifest.txt` file is written describing:
- Timestamp
- Source paths
- Destination path
- Copy success/failure count

---

## Requirements
- USB storage formatted as ext4, exFAT, or FAT32
- USB device detectable as a standard block device
- Uses standard Pager UI primitives:
  - `LOG`
  - `ERROR_DIALOG`
  - `TEXT_PICKER`

---

## Operator Notes
- This payload performs **copy only**, not move
- Large loot sets may take time to transfer
- If copy warnings occur, review the payload log
- Run the **USB Safe Unmount** payload after transfer before removing the USB

---

## Testing
Tested on WiFi Pineapple PAGER using:
- Multiple USB flash drives
- Mixed loot sizes (CSV, logs, directories)
- Cancel and confirmation paths

---

## License / Attribution
Authored by Stuffy24.  
No third-party code included.
