#!/bin/bash
# Title:        opkg Restore
# Description:  Reinstalls user-installed packages from backup after firmware update
# Author:       StuxMirai
# Version:      1.0

BACKUP_FILE="/root/user_installed_packages.txt"

LOG "Starting opkg package restore..."

if [ ! -f "$BACKUP_FILE" ]; then
    LOG "ERROR: Backup file not found at $BACKUP_FILE"
    ERROR_DIALOG "No backup file found. Run opkg_backup first."
    exit 1
fi

if [ ! -s "$BACKUP_FILE" ]; then
    LOG "ERROR: Backup file is empty"
    ERROR_DIALOG "Backup file exists but contains no packages"
    exit 1
fi

pkg_count=$(wc -l < "$BACKUP_FILE")
LOG "Found $pkg_count packages to restore"

LOG "Packages to restore:"
while IFS= read -r pkg; do
    LOG "  • $pkg"
done < "$BACKUP_FILE"

resp=$(CONFIRMATION_DIALOG "Restore $pkg_count packages? (Requires internet)")
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

LOG "Updating package index..."

if ! opkg update >/dev/null 2>&1; then
    LOG "WARNING: Package index update had errors"
    
    resp=$(CONFIRMATION_DIALOG "Package index update had errors. Continue anyway?")
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
    
    LOG "Continuing despite update errors..."
else
    LOG "Package index updated"
fi

LOG "Installing packages..."
installed_count=0
failed_count=0
failed_packages=""

while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    
    LOG "Installing: $pkg..."
    
    if opkg install "$pkg" >/dev/null 2>&1; then
        LOG "  ✓ $pkg installed"
        installed_count=$((installed_count + 1))
    else
        LOG "  ✗ $pkg failed"
        failed_count=$((failed_count + 1))
        failed_packages="$failed_packages $pkg"
    fi
done < "$BACKUP_FILE"

LOG "Restore complete"
LOG "Successfully installed: $installed_count"
LOG "Failed to install: $failed_count"

if [ "$failed_count" -gt 0 ]; then
    LOG "Failed packages:$failed_packages"
    ALERT "Restored $installed_count/$pkg_count packages. $failed_count failed."
else
    ALERT "Restored all $installed_count packages"
fi
