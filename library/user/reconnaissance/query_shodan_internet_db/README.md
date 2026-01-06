# Query Shodan InternetDB

**Author:** tototo31  
**Version:** 1.1  
**Category:** Reconnaissance  
**Target:** WiFi Pineapple Pager

## Description

This payload queries the Shodan InternetDB API to retrieve publicly available information about IP addresses and hostnames. InternetDB is a free API service provided by Shodan that aggregates data about internet-facing devices, including open ports, known vulnerabilities, hostnames, and more.

Perfect for:
- Quick reconnaissance of target IP addresses
- Identifying open ports on public-facing systems
- Discovering known vulnerabilities (CVEs)
- Gathering hostname information
- OSINT research and security assessments

## Features

- **IP Address & Hostname Support** - Query by IP address or hostname (auto-resolves via DNS)
- **Private IP Filtering** - Automatically rejects private, loopback, and invalid IP addresses
- **Comprehensive Data** - Retrieves ports, hostnames, CPEs, tags, and vulnerabilities
- **Formatted Output** - Clean, readable display of all information
- **Data Persistence** - Saves raw JSON responses to loot directory
- **Error Handling** - Comprehensive validation and error messages
- **DNS Resolution** - Automatically resolves hostnames to IP addresses using nslookup

## What is Shodan InternetDB?

Shodan InternetDB is a free, public API service that provides aggregated information about internet-facing devices. Unlike the main Shodan API, InternetDB does not require an API key and provides basic information including:

- **Open Ports** - Commonly exposed ports on the target
- **Hostnames** - Associated domain names
- **CPEs** - Common Platform Enumeration identifiers
- **Tags** - Device/service classifications
- **Vulnerabilities** - Known CVEs associated with the IP

**API Documentation:** https://internetdb.shodan.io/

## Prerequisites

### 1. Network Connectivity

The Pager must have internet access to query the Shodan InternetDB API.

### 2. Valid Public IP Address

The payload only accepts public IP addresses. Private IP ranges are automatically rejected:
- Private: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`
- Loopback: `127.0.0.0/8`
- Link-local: `169.254.0.0/16`
- Invalid: `0.0.0.0`
- Multicast/Reserved: `224.0.0.0/4` and above

## Usage

### Basic Usage

1. Copy the `query_shodan_internet_db` directory to your Pager:
   ```
   /payloads/library/user/reconnaissance/query_shodan_internet_db/
   ```

2. Run the payload via Pager UI

3. Enter an IP address or hostname when prompted

4. Review the results displayed in the logs

### Input Options

**IP Address:**
- Enter a valid public IPv4 address (e.g., `8.8.8.8`)
- The payload validates the format and rejects private IPs

**Hostname:**
- Enter a domain name (e.g., `google.com`, `example.org`)
- The payload automatically resolves the hostname to an IP address using `nslookup`
- If resolution fails, an error is displayed

### Example Queries

```
IP Address: 8.8.8.8
Hostname: google.com
Hostname: github.com
```

## Output

The payload displays the following information:

- **IP Address** - The queried IP (or resolved IP if hostname was provided)
- **Hostnames** - Associated domain names
- **Open Ports** - List of exposed ports
- **Tags** - Device/service classifications
- **CPEs** - Common Platform Enumeration identifiers
- **Vulnerabilities** - Known CVEs (Common Vulnerabilities and Exposures)

### Example Output

```
=== Query Results ===

IP Address: 8.8.8.8
Original Input: google.com (hostname)

Hostnames:
  - dns.google

Open Ports:
  - 53
  - 853

Tags:
  - dns

CPEs: None found

Vulnerabilities: None found
```

## Data Storage

All query results are automatically saved to:
```
/root/loot/shodan_internetdb/
```

Files are named with timestamp and target:
```
2024-01-15T12-30-45_8.8.8.8.json
2024-01-15T12-30-45_google.com.json
```

The raw JSON response is saved for later analysis or integration with other tools.

## Troubleshooting

### "Failed to resolve hostname"
- **Cause:** DNS resolution failed
- **Solution:** 
  - Verify the hostname is correct
  - Check network connectivity
  - Ensure DNS is working: `nslookup example.com`

### "Invalid or private IP address"
- **Cause:** Entered IP is in a private/reserved range
- **Solution:** Use a public IP address. Private IPs cannot be queried via InternetDB

### "API request failed"
- **Cause:** Network issue or API unavailable
- **Solution:**
  - Check internet connectivity
  - Verify the API is accessible: `curl https://internetdb.shodan.io/8.8.8.8`
  - Try again later if the service is down

### "Empty response from API"
- **Cause:** API returned no data
- **Solution:** This may indicate the IP has no data in Shodan's database. Try a different IP address.

### No Results Found
- **Cause:** The IP address may not have any data in Shodan InternetDB
- **Solution:** This is normal - not all IPs have data. Try querying well-known services (e.g., `8.8.8.8`, `1.1.1.1`)

## Limitations

- **IPv4 Only** - Currently supports IPv4 addresses only
- **Public IPs Only** - Private IP ranges are automatically rejected
- **Rate Limiting** - Shodan InternetDB is a free service; be respectful of rate limits
- **Data Availability** - Not all IP addresses have data in the database
- **No API Key Required** - Uses the free public API (no authentication needed)

## Security Notes

- This payload queries publicly available information only
- No authentication or API keys are required
- All queries are logged to the loot directory
- Use responsibly and in accordance with applicable laws
- Results may contain sensitive information - handle loot files appropriately

## API Reference

**Endpoint:** `https://internetdb.shodan.io/{ip}`

**Method:** GET

**Response Format:** JSON

**Example Response:**
```json
{
  "ip": "8.8.8.8",
  "hostnames": ["dns.google"],
  "ports": [53, 853],
  "tags": ["dns"],
  "cpes": [],
  "vulns": []
}
```

## Support

- **Shodan InternetDB:** https://internetdb.shodan.io/
- **Shodan Documentation:** https://www.shodan.io/
- **API Status:** Check Shodan's status page for service availability

## Changelog

### Version 1.1
- Added hostname support with automatic DNS resolution
- Added private IP address filtering
- Added validation for invalid/reserved IP ranges
- Improved error handling and user feedback

### Version 1.0
- Initial release
- Basic IP address querying
- JSON parsing and formatted output
- Loot file storage

