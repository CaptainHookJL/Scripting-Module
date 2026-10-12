#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <logfile>" >&2; exit 1; fi
LOGFILE=$1
if [ ! -f "$LOGFILE" ]; then echo "Error: file '$LOGFILE' not found" >&2; exit 2; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: file '$LOGFILE' cannot be read" >&2; exit 3; fi
FAILED=$(grep -c 'Failed password' -- "$LOGFILE")
STATUS=$?
if [ "$STATUS" -gt 1 ]; then exit "$STATUS"; fi
SOURCES=$(awk '/Failed password/ {for(i=1;i<NF;i++) if($i=="from") print $(i+1)}' "$LOGFILE" | sort | uniq -c | sort -nr)
TOP=$(printf '%s\n' "$SOURCES" | awk 'NR==1 {print $2}')
echo "Log file: $LOGFILE"
echo "Failed password events: $FAILED"
echo "Top attacker: ${TOP:-None}"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 3
bash "$SCRIPT_DIR/top3.sh" "$LOGFILE" || exit $?
echo "Top 3 targeted usernames:"
if [ "$FAILED" -eq 0 ]; then echo "None"; else
    awk '/Failed password/ {for(i=1;i<NF;i++) if($i=="for") {if($(i+1)=="invalid" && $(i+2)=="user") print $(i+3); else print $(i+1); break}}' "$LOGFILE" | sort | uniq -c | sort -nr | head -n 3
fi
exit 0
