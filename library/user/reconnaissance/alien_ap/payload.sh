#!/bin/bash
# Title: Alien AP
# Author: hannesrichter
# Description: This payload tries to identify APs that are sending beacons with wrong country code information.
# Version: 1.0

# Configuration
INTERFACE="wlan1mon"
IGNORE_CC="DE"  # ignore this country code
OFFSET="30"

# kill all childs (tcpdump, awk) when script exits
cleanup() {

    LOG "Cleaning up..."
    if [ ! -z "$WORKER_PID" ]; then
        kill $WORKER_PID 2>/dev/null
        wait $WORKER_PID 2>/dev/null
    fi
    exit
}
trap cleanup SIGINT SIGTERM EXIT

# main payload starts here...
LOG "using interface $INTERFACE"

IGNORE_CC=$(TEXT_PICKER "Which CC to ignore?" "DE")
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

LOG "Ignoring country: $IGNORE_CC"
LOG ""

(
    SEEN_LIST=""

    while read -r line; do

        regex="^TRIGGER ([^ ]+) ([^ ]+) SSID: (.*)$"

        if [[ $line =~ $regex ]]; then
            ascii="${BASH_REMATCH[1]}"
            hex="${BASH_REMATCH[2]}"
            station="${BASH_REMATCH[3]}"

            # check if we already have seen this MAC
            if [[ "$SEEN_LIST" != *"'$station'"* ]]; then

                LOG "$station is set to $ascii ($hex)"
                ALERT "$station is set to $ascii ($hex)"

                # append station name to seen list
                SEEN_LIST="$SEEN_LIST '$station'"
            fi

        fi

    done < <(tcpdump -l -i "$INTERFACE" -n -x -s 0 'type mgt subtype beacon' 2>/dev/null | \
             awk -v ignore_country="$IGNORE_CC" -v min_byte="$OFFSET" -f filter.awk)
)&

WORKER_PID=$!

wait $WORKER_PID
