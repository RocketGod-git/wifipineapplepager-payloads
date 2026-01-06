# Client Access Manager

### v1.0

**Author:** PanicAcid  
**Interface:** Client WiFi (`wlan0cli`)

---

## Overview

**Client Access Manager** is a management utility for the Hak5 WiFi Pineapple Pager. It provides a controlled method for enabling administrative access (Web UI and SSH) over the Client WiFi interface. This allows for remote device management via a local area network (LAN) without requiring a direct connection to the Management AP.

This tool implements a specific firewall exception for the Client interface while maintaining the default security posture of the device's other network zones.

---

## Functional Logic

This utility manages the OpenWrt firewall configuration through the following technical processes:

* **Rule Specification** The script defines a targeted `ACCEPT` rule for the `wan` zone, explicitly opening TCP ports `22` (SSH) and `1471` (Web UI).
  
* **Rule Prioritization** Utilizes `uci reorder` to position the management rule at the top of the firewall chain (Index 0). This ensures the exception is processed before the system's default rejection rules.

* **Interface Integration** Built using the Pager’s native `CONFIRMATION_DIALOG` system for hardware-level interaction, ensuring consistent behavior with official system payloads.

* **Network Status Reporting** Upon activation, the utility identifies the current IPv4 address assigned to the `wlan0cli` interface and outputs the full management URL to the system log.

* **Configuration Management** When access is revoked, the utility performs a full deletion of the custom rule from the configuration and restarts the firewall service to restore the factory security state.

---

## Usage

The utility functions as a state-aware toggle. The interface prompts will update based on the current configuration:

### Enabling Management Access
1. Connect the Pager to a local Wi-Fi network (Client Mode).
2. Execute **Client Access Manager** from the User menu.
3. Select 'Yes' when prompted: *"Management Access is LOCKED. Open on Client WiFi?"*
4. The system will display the active Client IP and management URL.

### Disabling Management Access
1. Execute the utility again from the User menu.
2. Select 'Yes' when prompted: *"Management Access is OPEN on Client WiFi. Lock it now?"*
3. The utility will remove the exception and reload the firewall configuration.

