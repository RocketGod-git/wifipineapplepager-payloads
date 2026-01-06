#!/bin/bash
# Title:                Query Shodan InternetDB
# Description:          Queries Shodan InternetDB API for information about an IP address or hostname
# Author:               tototo31
# Version:              1.1

# Options
LOOTDIR=/root/loot/shodan_internetdb

# Shodan InternetDB API endpoint
INTERNETDB_URL="https://internetdb.shodan.io"

# Helper function to extract JSON array values
extract_json_array() {
    local json="$1"
    local field="$2"
    # Extract the array content between [ and ]
    echo "$json" | sed -n "s/.*\"$field\"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p" | \
        sed 's/"//g' | sed 's/[[:space:]]*//g' | tr ',' '\n' | \
        sed '/^$/d'
}

# Helper function to extract JSON string value
extract_json_string() {
    local json="$1"
    local field="$2"
    echo "$json" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | \
        sed "s/\"$field\"[[:space:]]*:[[:space:]]*\"//;s/\"$//"
}

# Helper function to check if input is a valid IP address
is_ip_address() {
    local input="$1"
    # Check if input matches IPv4 pattern (basic validation)
    if echo "$input" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        # Validate each octet is 0-255
        IFS='.' read -r -a octets <<< "$input"
        for octet in "${octets[@]}"; do
            if [ "$octet" -gt 255 ] || [ "$octet" -lt 0 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Helper function to check if IP is private, invalid, or reserved
is_private_or_invalid_ip() {
    local ip="$1"
    IFS='.' read -r -a octets <<< "$ip"
    local o1=${octets[0]}
    local o2=${octets[1]}
    local o3=${octets[2]}
    local o4=${octets[3]}
    
    # Invalid IPs: 0.0.0.0
    if [ "$o1" -eq 0 ] && [ "$o2" -eq 0 ] && [ "$o3" -eq 0 ] && [ "$o4" -eq 0 ]; then
        return 0  # Is invalid
    fi
    
    # Loopback: 127.0.0.0/8
    if [ "$o1" -eq 127 ]; then
        return 0  # Is private/invalid
    fi
    
    # Private: 10.0.0.0/8
    if [ "$o1" -eq 10 ]; then
        return 0  # Is private
    fi
    
    # Private: 172.16.0.0/12 (172.16.0.0 to 172.31.255.255)
    if [ "$o1" -eq 172 ] && [ "$o2" -ge 16 ] && [ "$o2" -le 31 ]; then
        return 0  # Is private
    fi
    
    # Private: 192.168.0.0/16
    if [ "$o1" -eq 192 ] && [ "$o2" -eq 168 ]; then
        return 0  # Is private
    fi
    
    # Link-local: 169.254.0.0/16
    if [ "$o1" -eq 169 ] && [ "$o2" -eq 254 ]; then
        return 0  # Is link-local
    fi
    
    # Multicast: 224.0.0.0/4 (224.0.0.0 to 239.255.255.255)
    if [ "$o1" -ge 224 ] && [ "$o1" -le 239 ]; then
        return 0  # Is multicast
    fi
    
    # Reserved: 240.0.0.0/4 (240.0.0.0 to 255.255.255.255)
    if [ "$o1" -ge 240 ]; then
        return 0  # Is reserved
    fi
    
    # Broadcast: 255.255.255.255
    if [ "$o1" -eq 255 ] && [ "$o2" -eq 255 ] && [ "$o3" -eq 255 ] && [ "$o4" -eq 255 ]; then
        return 0  # Is broadcast
    fi
    
    return 1  # Is valid public IP
}

# Helper function to resolve hostname to IP address
resolve_hostname() {
    local hostname="$1"
    LOG "Resolving hostname: $hostname"
    
    # Use nslookup to resolve hostname
    # Try to get the first A record (IPv4 address)
    resolved_ip=$(nslookup "$hostname" 2>/dev/null | grep -A1 "Name:" | grep "Address:" | head -n1 | awk '{print $2}')
    
    if [ -z "$resolved_ip" ]; then
        # Alternative: try using getent or host command if nslookup format differs
        resolved_ip=$(nslookup "$hostname" 2>/dev/null | grep -E "^Address" | head -n1 | awk '{print $2}')
    fi
    
    if [ -z "$resolved_ip" ]; then
        # Last resort: try host command
        resolved_ip=$(host "$hostname" 2>/dev/null | grep "has address" | head -n1 | awk '{print $4}')
    fi
    
    if [ -z "$resolved_ip" ]; then
        return 1
    fi
    
    echo "$resolved_ip"
    return 0
}

LOG "=== Shodan InternetDB Query ==="
LOG ""

# Prompt user for IP address or hostname
LOG "Please enter an IP address or hostname to query..."
targetInput=$(TEXT_PICKER "Enter IP address or host" "8.8.8.8")

# Check if user cancelled or rejected
case $? in
    $DUCKYSCRIPT_CANCELLED)
        LOG "User cancelled"
        exit 1
        ;;
    $DUCKYSCRIPT_REJECTED)
        LOG "Dialog rejected"
        exit 1
        ;;
    $DUCKYSCRIPT_ERROR)
        LOG "An error occurred"
        exit 1
        ;;
esac

# Determine if input is IP address or hostname and resolve if needed
originalInput="$targetInput"
targetIP=""

if is_ip_address "$targetInput"; then
    LOG "Input detected as IP address: $targetInput"
    targetIP="$targetInput"
else
    LOG "Input detected as hostname: $targetInput"
    LOG "Resolving hostname to IP address..."
    resolved_ip=$(resolve_hostname "$targetInput")
    
    if [ -z "$resolved_ip" ]; then
        ERROR_DIALOG "Failed to resolve hostname: $targetInput"
        LOG "ERROR: Could not resolve hostname '$targetInput' to an IP address"
        LOG "Please check the hostname and network connectivity"
        exit 1
    fi
    
    targetIP="$resolved_ip"
    LOG "Resolved '$targetInput' to IP address: $targetIP"
fi

# Validate that the IP is not private, invalid, or reserved
if is_private_or_invalid_ip "$targetIP"; then
    ERROR_DIALOG "Invalid or private IP address"
    LOG "ERROR: IP address '$targetIP' is private, invalid, or reserved"
    LOG "Shodan InternetDB only supports public IP addresses"
    LOG ""
    LOG "The following IP ranges are not supported:"
    LOG "  - Private: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16"
    LOG "  - Loopback: 127.0.0.0/8"
    LOG "  - Link-local: 169.254.0.0/16"
    LOG "  - Invalid: 0.0.0.0"
    LOG "  - Multicast/Reserved: 224.0.0.0/4 and above"
    exit 1
fi

LOG ""
LOG "Querying Shodan InternetDB for: $targetIP"
if [ "$originalInput" != "$targetIP" ]; then
    LOG "(Original input: $originalInput)"
fi
LOG ""

# Create loot destination if needed
mkdir -p $LOOTDIR
# Use sanitized original input for filename (replace dots and special chars)
safe_input=$(echo "$originalInput" | tr '.:/' '_')
lootfile=$LOOTDIR/$(date -Is | tr ':' '-')_${safe_input}.json

# Query the API
api_url="${INTERNETDB_URL}/${targetIP}"
LOG "API URL: $api_url"
LOG ""

# Make the API request
response=$(curl -s -w "\n%{http_code}" "$api_url")
http_code=$(echo "$response" | tail -n1)
api_response=$(echo "$response" | sed '$d')

# Check HTTP status code
if [ "$http_code" != "200" ]; then
    ERROR_DIALOG "API request failed (HTTP $http_code)"
    LOG "ERROR: API request failed with HTTP status $http_code"
    if [ -n "$api_response" ]; then
        LOG "Response: $api_response"
    fi
    exit 1
fi

# Check if response is empty or invalid JSON
if [ -z "$api_response" ]; then
    ERROR_DIALOG "Empty response from API"
    LOG "ERROR: Received empty response from API"
    exit 1
fi

# Save raw response to loot file
echo "$api_response" > "$lootfile"
LOG "Raw response saved to: $lootfile"
LOG ""

# Parse and display results
LOG "=== Query Results ==="
LOG ""

# Extract fields from JSON response
ip=$(extract_json_string "$api_response" "ip")
hostnames=$(extract_json_array "$api_response" "hostnames")
ports=$(extract_json_array "$api_response" "ports")
tags=$(extract_json_array "$api_response" "tags")
cpes=$(extract_json_array "$api_response" "cpes")
vulns=$(extract_json_array "$api_response" "vulns")

# Display IP
if [ -n "$ip" ]; then
    LOG "IP Address: $ip"
else
    LOG "IP Address: $targetIP"
fi
if [ "$originalInput" != "$targetIP" ]; then
    LOG "Original Input: $originalInput (hostname)"
fi
LOG ""

# Display hostnames
if [ -n "$hostnames" ]; then
    LOG "Hostnames:"
    echo "$hostnames" | while read -r hostname; do
        if [ -n "$hostname" ]; then
            LOG "  - $hostname"
        fi
    done
    LOG ""
else
    LOG "Hostnames: None found"
    LOG ""
fi

# Display ports
if [ -n "$ports" ]; then
    LOG "Open Ports:"
    echo "$ports" | while read -r port; do
        if [ -n "$port" ]; then
            LOG "  - $port"
        fi
    done
    LOG ""
else
    LOG "Open Ports: None found"
    LOG ""
fi

# Display tags
if [ -n "$tags" ]; then
    LOG "Tags:"
    echo "$tags" | while read -r tag; do
        if [ -n "$tag" ]; then
            LOG "  - $tag"
        fi
    done
    LOG ""
else
    LOG "Tags: None found"
    LOG ""
fi

# Display CPEs
if [ -n "$cpes" ]; then
    LOG "CPEs (Common Platform Enumeration):"
    echo "$cpes" | while read -r cpe; do
        if [ -n "$cpe" ]; then
            LOG "  - $cpe"
        fi
    done
    LOG ""
else
    LOG "CPEs: None found"
    LOG ""
fi

# Display vulnerabilities
if [ -n "$vulns" ]; then
    LOG "Vulnerabilities:"
    echo "$vulns" | while read -r vuln; do
        if [ -n "$vuln" ]; then
            LOG "  - $vuln"
        fi
    done
    LOG ""
else
    LOG "Vulnerabilities: None found"
    LOG ""
fi

LOG "=== Query Complete ==="
LOG "Results saved to: $lootfile"

