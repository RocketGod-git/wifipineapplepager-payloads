# NMap Host Discovery

**Author:** tototo31  
**Version:** 1.0  
**Category:** Reconnaissance  
**Target:** WiFi Pineapple Pager

## Description

This payload performs network host discovery scans using NMap to identify live hosts on a selected subnet. Unlike full port scans, host discovery focuses solely on finding active devices without probing ports, making it faster and less intrusive.

Perfect for:
- Network reconnaissance and mapping
- Identifying active devices on a network
- Quick network inventory
- Discovering hosts before deeper scanning
- Network topology discovery

## Features

- **Automatic Subnet Detection** - Automatically discovers available subnets from network interfaces
- **Subnet Normalization** - Converts device IP addresses to proper network addresses (e.g., `192.168.1.100/24` → `192.168.1.0/24`)
- **All Prefix Lengths Supported** - Works with any subnet mask (/8 through /32)
- **Multiple Discovery Methods** - Uses ICMP echo, ICMP timestamp, TCP SYN, and TCP ACK ping
- **Interactive Selection** - User-friendly interface to select target subnet
- **Comprehensive Output** - Results saved in multiple formats (XML, normal, grepable)
- **Real-time Logging** - Live output streamed to logs during scan

## How It Works

1. **Subnet Discovery**: Scans network interfaces to find all connected subnets
2. **Subnet Normalization**: Converts device IPs to network addresses using subnet mask calculation
3. **User Selection**: Displays available subnets and prompts user to select target
4. **Host Discovery Scan**: Runs NMap with multiple discovery techniques:
   - `-sn`: Ping scan (no port scan)
   - `-PE`: ICMP echo request ping
   - `-PP`: ICMP timestamp request ping
   - `-PS`: TCP SYN ping
   - `-PA`: TCP ACK ping
5. **Results Storage**: Saves scan results in multiple formats to loot directory

## Prerequisites

### 1. NMap Installation

NMap must be installed on the Pager. Verify with:
```bash
which nmap
```

If not installed, install via package manager:
```bash
opkg update && opkg install nmap
```

### 2. Network Interface

The Pager must have at least one active network interface with an assigned IP address.

## Usage

### Basic Usage

1. Copy the `nmap_host_discovery` directory to your Pager:
   ```
   /payloads/library/user/reconnaissance/nmap_host_discovery/
   ```

2. Run the payload via Pager UI

3. Review available subnets displayed in the prompt

4. Enter the index number of the target subnet

5. Wait for scan to complete and review results

### Example Workflow

```
1. Payload starts
2. Displays available subnets:
   1 192.168.1.0/24
   2 10.0.0.0/16
   3 172.16.0.0/12
3. User enters: 1
4. Scan runs on 192.168.1.0/24
5. Results displayed in logs and saved to loot
```

## Subnet Normalization

The payload automatically normalizes subnet addresses to ensure accurate scanning:

**Examples:**
- Device IP: `192.168.1.100/24` → Network: `192.168.1.0/24`
- Device IP: `10.0.5.50/16` → Network: `10.0.0.0/16`
- Device IP: `172.16.5.10/28` → Network: `172.16.5.0/28`
- Device IP: `192.168.1.130/25` → Network: `192.168.1.128/25`

This ensures that the entire subnet is scanned, not just the device's specific IP address.

## Output

### Console Output

The payload streams real-time scan results to the log, including:
- Scan progress
- Discovered hosts with IP addresses
- MAC addresses (when available)
- Hostnames (when resolvable)
- Response times

### Example Output

```
Running nmap host discovery scan on 192.168.1.0/24...
Results will be saved to: /root/loot/nmapHostDiscovery/2024-01-15T12-30-45

Starting Nmap 7.94 ( https://nmap.org ) at 2024-01-15 12:30 UTC
Nmap scan report for 192.168.1.1
Host is up (0.002s latency).
MAC Address: AA:BB:CC:DD:EE:FF (Router Manufacturer)

Nmap scan report for 192.168.1.100
Host is up (0.005s latency).

Nmap scan report for 192.168.1.150
Host is up (0.003s latency).
MAC Address: 11:22:33:44:55:66 (Device Manufacturer)

Nmap done: 256 IP addresses (3 hosts up) scanned in 5.23 seconds

Host discovery scan completed!
```

## Data Storage

All scan results are automatically saved to:
```
/root/loot/nmapHostDiscovery/
```

Files are named with ISO timestamp:
```
2024-01-15T12-30-45.xml      # XML format
2024-01-15T12-30-45.nmap     # Normal format
2024-01-15T12-30-45.gnmap    # Grepable format
```

### File Formats

- **`.xml`**: XML format for parsing and integration with other tools
- **`.nmap`**: Human-readable normal format
- **`.gnmap`**: Grepable format for script processing

## NMap Discovery Techniques

The payload uses multiple discovery methods to maximize host detection:

1. **ICMP Echo (`-PE`)**: Standard ping request
2. **ICMP Timestamp (`-PP`)**: ICMP timestamp request (bypasses some firewalls)
3. **TCP SYN Ping (`-PS`)**: TCP SYN packet to common ports
4. **TCP ACK Ping (`-PA`)**: TCP ACK packet (bypasses stateless firewalls)

This combination increases the likelihood of detecting hosts even when ICMP is blocked.

## Troubleshooting

### "No subnets found"
- **Cause:** No network interfaces with assigned IP addresses
- **Solution:** 
  - Verify network connectivity
  - Check interface status: `ip addr show`
  - Ensure at least one interface has an IP address

### "Nmap command not found"
- **Cause:** NMap is not installed
- **Solution:** Install NMap: `opkg update && opkg install nmap`

### "No hosts found"
- **Cause:** No active hosts on the subnet, or all hosts are blocking discovery probes
- **Solution:** 
  - Verify you're scanning the correct subnet
  - Some networks may block all discovery methods
  - Try scanning a known active subnet (e.g., your local network)

### Scan takes too long
- **Cause:** Large subnet or slow network
- **Solution:** 
  - This is normal for large subnets (e.g., /16, /8)
  - Consider scanning smaller subnets first
  - The scan will complete; be patient

### Incorrect subnet displayed
- **Cause:** Subnet normalization calculation error
- **Solution:** 
  - Verify the displayed subnet matches your network configuration
  - Check network settings: `ip addr show`
  - Report the issue with subnet details

## Limitations

- **IPv4 Only** - Currently supports IPv4 addresses only
- **Local Network** - Designed for scanning local/connected networks
- **Firewall Impact** - Hosts with strict firewalls may not respond to any discovery method
- **Scan Time** - Large subnets (e.g., /8, /16) can take significant time to scan
- **Network Load** - Scanning large subnets may generate significant network traffic

## Security Notes

- **Authorized Use Only** - Only scan networks you own or have explicit permission to scan
- **Network Impact** - Host discovery generates network traffic; be mindful of network load
- **Detection** - Discovery scans may be logged by network monitoring systems
- **Legal Compliance** - Ensure all scanning activities comply with local laws and regulations
- **Results Storage** - Scan results contain network information; handle loot files appropriately

## Advanced Usage

### Customizing Scan Options

To modify scan behavior, edit the `payload.sh` file and adjust the NMap command on line 102:

```bash
# Current command:
nmap -sn -PE -PP -PS -PA -oA $lootfile $targetSubnet

# Example: Add specific ports for TCP ping
nmap -sn -PE -PP -PS22,80,443 -PA22,80,443 -oA $lootfile $targetSubnet

# Example: Increase scan speed (may miss some hosts)
nmap -sn -PE -T4 -oA $lootfile $targetSubnet
```

### Scanning Specific Subnets

To scan a specific subnet without selection, modify the payload to accept input or hardcode a subnet.

### Integration with Other Tools

The XML output format can be parsed by various security tools:
- Import into network mapping tools
- Feed into vulnerability scanners
- Process with custom scripts
- Import into SIEM systems

## NMap Documentation

For more information on NMap host discovery:
- **Official Documentation:** https://nmap.org/book/man-host-discovery.html
- **NMap Reference Guide:** https://nmap.org/book/man.html

## Support

- **NMap Official Site:** https://nmap.org/
- **NMap Book:** https://nmap.org/book/
- **Community Forums:** https://nmap.org/book/community.html

## Changelog

### Version 1.0
- Initial release
- Automatic subnet detection and normalization
- Support for all prefix lengths (/8 through /32)
- Multiple discovery techniques (ICMP echo, ICMP timestamp, TCP SYN, TCP ACK)
- Multiple output formats (XML, normal, grepable)
- Real-time logging and progress display

