#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <logfile>" >&2; exit 1; fi
LOG=$1
if [ ! -f "$LOG" ]; then echo "Error: file not found: $LOG" >&2; exit 2; fi
if [ ! -s "$LOG" ]; then echo "Error: empty file: $LOG" >&2; exit 3; fi
if [ ! -r "$LOG" ]; then echo "Error: unreadable file: $LOG" >&2; exit 2; fi
LINES=$(wc -l < "$LOG") || exit 2
FAILED=$(grep -cF 'Failed password' -- "$LOG"); STATUS=$?
[ "$STATUS" -le 1 ] || exit 2
ACCEPTED=$(grep -cF 'Accepted password' -- "$LOG"); STATUS=$?
[ "$STATUS" -le 1 ] || exit 2
FIRST=$(awk 'NR==1 {print $1,$2,$3; exit}' "$LOG") || exit 2
LAST=$(awk 'END {print $1,$2,$3}' "$LOG") || exit 2
printf 'File     : %s\nLines    : %s\nFailed   : %s\nAccepted : %s\nFirst    : %s\nLast     : %s\n' "$LOG" "$LINES" "$FAILED" "$ACCEPTED" "$FIRST" "$LAST"
exit 0
