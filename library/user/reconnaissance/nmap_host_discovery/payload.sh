#!/bin/bash
# Title:                NMap Host Discovery
# Description:          Performs host discovery scan on selected subnet and saves results to both storage and log
# Author:               tototo31
# Version:              1.0

# Options
LOOTDIR=/root/loot/nmapHostDiscovery

# Function to normalize CIDR to network address
normalize_subnet() {
    local cidr=$1
    local ip=$(echo $cidr | cut -d'/' -f1)
    local prefix=$(echo $cidr | cut -d'/' -f2)
    
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    
    # Calculate network address by applying subnet mask based on prefix length
    # The prefix length tells us how many bits are network bits (the rest are host bits)
    local n1=$i1 n2=$i2 n3=$i3 n4=$i4
    
    if [ $prefix -ge 24 ]; then
        # Network bits cover first 3 octets completely, partial 4th octet
        # Zero out the last (32 - prefix) bits in the 4th octet
        local host_bits=$((32 - prefix))
        if [ $host_bits -gt 0 ] && [ $host_bits -le 8 ]; then
            # Calculate mask: 256 - 2^host_bits
            # This creates a mask that keeps network bits, zeros host bits
            local mask=$((256 - (1 << host_bits)))
            n4=$((i4 & mask))
        elif [ $host_bits -eq 0 ]; then
            # /32 - single host, no change needed
            :
        else
            # Shouldn't happen, but zero the octet if host_bits > 8
            n4=0
        fi
    elif [ $prefix -ge 16 ]; then
        # Network bits cover first 2 octets completely, partial 3rd octet
        # Zero out the last (24 - prefix) bits in the 3rd octet, all of 4th octet
        local host_bits=$((24 - prefix))
        if [ $host_bits -gt 0 ] && [ $host_bits -le 8 ]; then
            local mask=$((256 - (1 << host_bits)))
            n3=$((i3 & mask))
        fi
        n4=0
    elif [ $prefix -ge 8 ]; then
        # Network bits cover first octet completely, partial 2nd octet
        # Zero out the last (16 - prefix) bits in the 2nd octet, all of 3rd and 4th octets
        local host_bits=$((16 - prefix))
        if [ $host_bits -gt 0 ] && [ $host_bits -le 8 ]; then
            local mask=$((256 - (1 << host_bits)))
            n2=$((i2 & mask))
        fi
        n3=0
        n4=0
    else
        # Network bits are partial in first octet
        # Zero out the last (8 - prefix) bits in the 1st octet, all of 2nd, 3rd, and 4th octets
        local host_bits=$((8 - prefix))
        if [ $host_bits -gt 0 ] && [ $host_bits -le 8 ]; then
            local mask=$((256 - (1 << host_bits)))
            n1=$((i1 & mask))
        fi
        n2=0
        n3=0
        n4=0
    fi
    
    echo "$n1.$n2.$n3.$n4/$prefix"
}

# Get and format connected subnets from network interfaces
raw_subnets=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
subnetArray=()
while IFS= read -r cidr; do
    if [ -n "$cidr" ]; then
        normalized=$(normalize_subnet "$cidr")
        subnetArray+=("$normalized")
    fi
done <<< "$raw_subnets"

subnetPrompt=$(printf '%s\n' "${subnetArray[@]}" | awk '{print NR,$0}')

# Prompt user to select a subnet to target
PROMPT "Target subnets:\n\n$subnetPrompt"
targetIndex=$(NUMBER_PICKER "Enter index of target" "1")
targetSubnet=${subnetArray[$targetIndex-1]}

# Create loot destination if needed
mkdir -p $LOOTDIR
lootfile=$LOOTDIR/$(date -Is)

LOG "Running nmap host discovery scan on $targetSubnet..."
LOG "Results will be saved to: $lootfile\n"

# Run host discovery scan (-sn: ping scan, no port scan)
# -PE: ICMP echo request
# -PP: ICMP timestamp request
# -PS: TCP SYN ping
# -PA: TCP ACK ping
nmap -sn -PE -PP -PS -PA -oA $lootfile $targetSubnet | tr '\n' '\0' | xargs -0 -n 1 LOG

LOG "\nHost discovery scan completed!"

