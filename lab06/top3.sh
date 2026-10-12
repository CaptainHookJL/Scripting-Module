#!/bin/bash

LOGFILE=${1:-case/logs/auth.log}
if [ ! -f "$LOGFILE" ]; then echo "Error: file '$LOGFILE' not found" >&2; exit 2; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: file '$LOGFILE' cannot be read" >&2; exit 3; fi
TOP_ATTACKERS=$(awk '/Failed password/ {for(i=1;i<NF;i++) if($i=="from") print $(i+1)}' "$LOGFILE" | sort | uniq -c | sort -nr | head -n 3)
echo "Top 3 failed-login sources:"
printf '%s\n' "${TOP_ATTACKERS:-None}"
