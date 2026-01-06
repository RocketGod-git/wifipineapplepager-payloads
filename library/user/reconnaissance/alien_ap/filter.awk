BEGIN {
    if (min_byte == "") min_byte = 30
    start_pos = (min_byte * 2) + 1
    hextable = "0123456789abcdef"
    
    if (ignore_country == "") ignore_country = "DE"
}

/Beacon/ {
    if (payload != "") check_packet(header, payload)
    header = $0
    payload = ""
}

# Hex-Parsing (Tolerant gegenüber Formaten)
/0x[0-9a-f]+:/ {
    raw_line = $0
    sub(/.*:/, "", raw_line)
    gsub(/[ \t]/, "", raw_line)
    payload = payload raw_line
}

function check_packet(hdr, pyld) {
    if (length(pyld) < 20) return

    work_str = substr(pyld, start_pos)
    
    # search for a pattern of hex strings starting with 07 as this is the field id of language codes
    while (match(work_str, /07....../)) {
        
        # extract the substring (07 + length + ASCII-code)
        # example "07064445" for "DE" Germany
        found_full = substr(work_str, RSTART, 8)
        
        # get the last 2 bytes
        c_hex1 = substr(found_full, 5, 2) # Erstes Byte (z.B. 55)
        c_hex2 = substr(found_full, 7, 2) # Zweites Byte (z.B. 53)
        
        # convert to numbers
        d1 = hex2dec(c_hex1)
        d2 = hex2dec(c_hex2)
        
        # This check is very important!
        # we will only proceed if the numbers could be interpreted as valid ascii characters
        # ASCII 'A' is 65, 'Z' is 90.
        if (d1 >= 65 && d1 <= 90 && d2 >= 65 && d2 <= 90) {
            
            # print ascii hex to string
            found_ascii = sprintf("%c%c", d1, d2)
            
            if (found_ascii != ignore_country) {

                # extract the station name from the header line
                if (match(hdr, /Beacon \([^)]+\)/)) {
                    full_match = substr(hdr, RSTART, RLENGTH)
                    open_paren = index(full_match, "(")
                    ssid = substr(full_match, open_paren + 1, length(full_match) - open_paren - 1)                    
                }
                
                print "TRIGGER " found_ascii " " c_hex1 c_hex2 " SSID: " ssid 
                fflush()
                return 
            }
        }
        
        # keep looking...
        work_str = substr(work_str, RSTART + 1)
    }
}

function hex2dec(h) {
    l = length(h)
    val = 0
    for (i = 1; i <= l; i++) {
        char = tolower(substr(h, i, 1))
        val = val * 16 + (index(hextable, char) - 1)
    }
    return val
}
