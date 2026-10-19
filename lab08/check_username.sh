#!/bin/bash
set -o pipefail

if [ $# -ne 2 ] || [ -z "$2" ]; then echo "Usage: $0 <logfile> <search_term>" >&2; exit 1; fi
LOGFILE=$1
if [ ! -f "$LOGFILE" ]; then echo "Error: '$LOGFILE' is not a regular file" >&2; exit 2; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: '$LOGFILE' is unreadable" >&2; exit 4; fi
USERNAME=$2
STATS=$(awk -v name="$USERNAME" '
    /Failed password for / || /Accepted password for / {
        for (i=1;i<NF;i++) if ($i=="for") {
            j=i+1; if ($j=="invalid" && $(j+1)=="user") j+=2
            if ($j==name) {if ($0 ~ /Failed password/) failed++; else accepted++}
            break
        }
    }
    END {print failed+0, accepted+0}
' "$LOGFILE") || exit 4
read -r FAILS ACCEPTS <<< "$STATS"
ACTIVITY=$(awk -v name="$USERNAME" '
    {for(i=1;i<NF;i++) if($i=="for") {
        j=i+1; if($j=="invalid" && $(j+1)=="user") j+=2
        if($j==name) count++; break
    }} END {print count+0}
' "$LOGFILE") || exit 4
if [ "$ACTIVITY" -eq 0 ]; then echo "$USERNAME: no activity found"; exit 3; fi
if [ "$FAILS" -gt 0 ]; then echo "$USERNAME: $FAILS failed and $ACCEPTS accepted login(s) — investigate"
elif [ "$ACCEPTS" -gt 0 ]; then echo "$USERNAME: $ACCEPTS successful login(s) only"
else echo "$USERNAME: other activity found, but no failed or accepted password logins"; fi
if [ "$FAILS" -gt 5 ]; then echo "HIGH RISK"; fi
