# opkg Restore

**Author:** StuxMirai  
**Version:** 1.0  
**Category:** General

## Description

Reinstalls user-installed packages from a backup created by **opkg Backup**.

After a firmware update, the WiFi Pineapple Pager [loses packages installed via `opkg`](https://docs.hak5.org/wifi-pineapple-pager/updating/software-updates/). This payload reads your backup file and reinstalls all your previously installed packages.

## Prerequisites

- Previously run **opkg Backup** before performing a firmware update
- Device must have internet connectivity for package downloads

## Backup Location

```
/root/user_installed_packages.txt
```

> **Note:** There are definitely automated ways to accomplish package persistence, but sometimes a simple manual approach is still a nice option.

