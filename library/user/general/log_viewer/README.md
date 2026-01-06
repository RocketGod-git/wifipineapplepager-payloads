# Log Viewer

**Log Viewer** is a high-performance log analysis tool for the WiFi Pineapple Pager.

---

### Features
* **New Headless Mode:** Use Log Viewer to parse your log file and output to the console right from your payload!
* **Turbo Batching:** Renders 50+ lines of log data instantly using compiled buffers.
* **Dual View Modes:** Choose between **Parsed** (Deconstructed Color) or **Raw** (Standard Text).
* **D-Pad Navigation:** Vertical up/down scrolling of log files for easier access.
* **Large File Safety:** Automatically detects massive files and offers to "Tail" (view the last 60 lines) to prevent device freezing.
---

### Workflow Tutorial

**1. Select Loot Folder**
The payload begins by scanning your `/root/loot` directory. It presents a vertical list of all available folders.
* *Note: Press Enter to 'scroll' if the list exceeds the screen size.*

![Folder List](screens/Capture_01.png)

**2. Enter Folder ID**
Input the ID number of the folder you wish to inspect.

![Folder ID](screens/Capture_02.png)

**3. Select File**
The tool lists all compatible files (logs, nmap scans, XMLs) within that folder.

![File List](screens/Capture_03.png)

**4. Enter File ID**
Input the ID number of the specific file to view.

![File ID](screens/Capture_04.png)

**5. Select View Mode**
Choose how you want the data displayed:
* **1. Parsed Log:** Breaks lines into Color-Coded sections (Time/Status/IP).
* **2. Raw Log:** Displays the file exactly as it was saved.

![View Mode](screens/Capture_05.png)

**6. Confirm Selection**
Use the number picker to confirm your mode.

![Mode Select](screens/Capture_06.png)

**7. Render Log**
The tool compiles the render script. Press **OK** to generate the view.

![Render](screens/Capture_07.png)

**8. Analysis View**
The log is displayed on screen.
* **Yellow:** Timestamp
* **Blue:** IP or MAC Address
* **Green/Red:** Status (Success/Failure)
* **White:** General Info

![Final View](screens/Capture_08.png)

---

## Integration / Headless Usage

You can call the Log Viewer from any other script (like Blue Clues or Counter Snoop) by passing arguments directly.

### Arguments

| Position | Argument | Description | Options |
| :--- | :--- | :--- | :--- |
| **$1** | `File Path` | Absolute path to the log file. | `/root/loot/scan.txt` |
| **$2** | `Mode` | How the log should be rendered. | `1` = **Parsed** (Color)<br>`2` = **Raw** (Text) |

### Example Command

To open a specific log file immediately in **Color Mode**:

```bash
/root/payloads/user/general/log_viewer/payload.sh "/root/loot/blue_clues/scan_results.txt" 1
```

### Headless Examples

**1. Basic Integration (Standard)**
Use this to automatically launch the viewer at the end of a script.

```bash
# === ADD TO END OF PAYLOAD ===
VIEWER="/root/payloads/user/general/log_viewer/payload.sh"

if [ -f "$VIEWER" ]; then
    # Launch in Parsed/Color Mode (1)
    /bin/bash "$VIEWER" "$LOG_FILE" 1
fi
```

**2. Interactive Choice**

```
# === ADD TO END OF PAYLOAD ===
VIEWER="/root/payloads/user/general/log_viewer/payload.sh"

PROMPT "SCAN COMPLETE

1. View Log Now
2. Exit

Press OK."
CHOICE=$(NUMBER_PICKER "Select Option" 1)

if [ "$CHOICE" -eq 1 ] && [ -f "$VIEWER" ]; then
    /bin/bash "$VIEWER" "$LOG_FILE" 1
fi
```

