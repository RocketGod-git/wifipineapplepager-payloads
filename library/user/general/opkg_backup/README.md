# opkg Backup

**Author:** StuxMirai  
**Version:** 1.0  
**Category:** General

## Description

Backs up user-installed packages to a file that survives firmware updates.

The WiFi Pineapple Pager [preserves the `/root/` directory during upgrades](https://docs.hak5.org/wifi-pineapple-pager/updating/software-updates/), but packages installed via `opkg` are lost. This payload creates a list of your user-installed packages so they can be easily reinstalled after an update.

## Backup Location

```
/root/user_installed_packages.txt
```

---

> **Note:** There are definitely automated ways to accomplish package persistence, but sometimes a simple manual approach is still a nice option.

