#!/bin/bash
# Title: Client Access Manager
# Author: PanicAcid
# Description: Toggles SSH and Web UI access on the Client WiFi interface.
# Version: 1.1

RULE_NAME="dev_access_rule"

# 1. State Verification
# Checks the uci configuration to determine if the management rule is active.
CURRENT_STATE=$(uci get firewall.$RULE_NAME.enabled 2>/dev/null || echo "0")

if [ "$CURRENT_STATE" == "1" ]; then
    MSG="Management Access is OPEN on Client WiFi. Lock it now?"
else
    MSG="Management Access is LOCKED. Open on Client WiFi?"
fi

# 2. User Interaction
# Utilizes the native Pager hardware dialog system.
RESP=$(CONFIRMATION_DIALOG "$MSG")

# 3. Execution Logic
case "$RESP" in
    $DUCKYSCRIPT_USER_CONFIRMED)
        if [ "$CURRENT_STATE" == "1" ]; then
            LOG "Revoking management access..."
            
            # Remove the custom firewall rule to restore factory security state.
            uci delete firewall.$RULE_NAME 2>/dev/null
            uci commit firewall
            fw4 restart
            
            LOG "[*] Access Restricted"
            LOG "[*] Re-run payload to re-enable access."
        else
            LOG "Configuring firewall exception..."
            
            # Define a targeted ACCEPT rule for the wan (Client WiFi) zone.
            uci set firewall.$RULE_NAME=rule
            uci set firewall.$RULE_NAME.name='Allow-Dev-Access'
            uci set firewall.$RULE_NAME.src='wan'
            uci set firewall.$RULE_NAME.dest_port='22 1471'
            uci set firewall.$RULE_NAME.proto='tcp'
            uci set firewall.$RULE_NAME.target='ACCEPT'
            uci set firewall.$RULE_NAME.enabled='1'
            
            # Prioritize the rule at Index 0 to ensure it precedes default reject rules.
            uci reorder firewall.$RULE_NAME=0
            
            uci commit firewall
            fw4 restart
            
            # Allow network stack to settle before interface querying.
            sleep 1
            
            # Retrieve IPv4 address for the wlan0cli interface.
            CLIENT_IP=$(ifconfig wlan0cli 2>/dev/null | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
            
            if [ -z "$CLIENT_IP" ]; then
                CLIENT_IP=$(ip -4 addr show wlan0cli 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
            fi

            LOG "[*] Access Granted"
            if [ -n "$CLIENT_IP" ]; then
                LOG "[*] UI: http://${CLIENT_IP}:1471"
            else
                LOG "[!] Warning: No Client IP detected"
            fi
            LOG "[*] Re-run payload to remove access."
        fi
        ;;
    $DUCKYSCRIPT_USER_DENIED)
        LOG "Operation cancelled by user."
        ;;
    *)
        exit 0
        ;;
esac