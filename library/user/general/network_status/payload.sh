#!/bin/bash
# Title: Network Status Diagnostic
# Author: spencershepard (GRIMM)
# Description: Displays network connectivity status for all interfaces
# Version: 1.0

LOG "Gathering network interface status..."

# List all network interfaces except loopback

for iface in $(ls /sys/class/net | grep -v lo); do
    status="DOWN"
    if ip link show "$iface" | grep -q 'state UP'; then
        status="UP"
    fi
    ipaddr=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    [ -z "$ipaddr" ] && ipaddr="No IP"
    LOG "$iface: $status, IP: $ipaddr"
    # Test connectivity if interface is up and has IP
    if [ "$status" = "UP" ] && [ "$ipaddr" != "No IP" ]; then
        if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
            LOG "  Internet: Reachable"
        else
            LOG "  Internet: Unreachable"
        fi
    fi
done