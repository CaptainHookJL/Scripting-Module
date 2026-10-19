#!/bin/bash
set -o pipefail

if [ $# -ne 1 ] || [ -z "$1" ]; then echo "Usage: $0 <path>" >&2; exit 1; fi
USERNAME=$1
LOG="case/logs/auth.log"
if [ ! -f "$LOG" ]; then echo "Error: '$LOG' is not a regular file" >&2; exit 2; fi
if [ ! -r "$LOG" ]; then echo "Error: '$LOG' is unreadable" >&2; exit 4; fi
SOURCES=$(awk -v name="$USERNAME" '/Accepted password for / {
    for(i=1;i<NF;i++) if($i=="for" && $(i+1)==name) {
        for(j=i+2;j<NF;j++) if($j=="from") print $(j+1)
        break
    }
}' "$LOG" | sort -u)
if [ -z "$SOURCES" ]; then echo "$USERNAME: no successful logins"
else
    COUNT=$(printf '%s\n' "$SOURCES" | wc -l)
    echo "$USERNAME logged in from $COUNT different address(es):"
    printf '%s\n' "$SOURCES"
fi
