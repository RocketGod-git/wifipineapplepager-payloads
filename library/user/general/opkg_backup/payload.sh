#!/bin/bash
# Title:        opkg Backup
# Description:  Backs up user-installed packages to a file that survives firmware updates
# Author:       StuxMirai
# Version:      1.0

BACKUP_FILE="/root/user_installed_packages.txt"

LOG "Starting opkg package backup..."

if [ -f "$BACKUP_FILE" ]; then
    existing_count=$(wc -l < "$BACKUP_FILE" 2>/dev/null || echo "0")
    LOG "Existing backup found with $existing_count packages"
    
    resp=$(CONFIRMATION_DIALOG "Overwrite existing backup? ($existing_count packages)")
    case $? in
        $DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
            LOG "Dialog rejected"
            exit 1
            ;;
    esac
    
    case "$resp" in
        $DUCKYSCRIPT_USER_DENIED)
            LOG "User cancelled"
            exit 0
            ;;
    esac
fi

LOG "Gathering user-installed packages..."

all_packages=$(opkg list-installed 2>/dev/null | awk '{print $1}')

if [ -z "$all_packages" ]; then
    LOG "ERROR: Could not retrieve package list"
    ERROR_DIALOG "Failed to retrieve installed package list"
    exit 1
fi

temp_file=$(mktemp 2>/dev/null || echo "/tmp/opkg_backup_$$")

pkg_count=0
for pkg in $all_packages; do
    if opkg status "$pkg" 2>/dev/null | grep -q "user installed"; then
        echo "$pkg" >> "$temp_file"
        pkg_count=$((pkg_count + 1))
    fi
done

if [ "$pkg_count" -eq 0 ]; then
    LOG "No user-installed packages found"
    ALERT "No user-installed packages to backup"
    rm -f "$temp_file"
    exit 0
fi

mv "$temp_file" "$BACKUP_FILE"

LOG "Packages backed up: $pkg_count"
LOG "Backup location: $BACKUP_FILE"

LOG "User-installed packages:"
while IFS= read -r pkg; do
    LOG "  • $pkg"
done < "$BACKUP_FILE"

ALERT "Backed up $pkg_count packages"
