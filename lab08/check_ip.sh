#!/bin/bash
set -o pipefail

if [ $# -ne 2 ] || [ -z "$2" ]; then echo "Usage: $0 <logfile> <search_term>" >&2; exit 1; fi
LOGFILE=$1
if [ ! -f "$LOGFILE" ]; then echo "Error: '$LOGFILE' is not a regular file" >&2; exit 2; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: '$LOGFILE' is unreadable" >&2; exit 4; fi
IP=$2
COUNT=$(grep -cwF -- "$IP" "$LOGFILE")
STATUS=$?
if [ "$STATUS" -gt 1 ]; then exit 4; fi
if [ "$COUNT" -gt 0 ]; then echo "FOUND: $IP appears $COUNT time(s) in $LOGFILE"; exit 0
else echo "NOT FOUND: $IP does not appear in $LOGFILE"; exit 3; fi
