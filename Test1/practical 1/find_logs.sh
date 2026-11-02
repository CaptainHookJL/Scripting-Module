#!/bin/bash
if [ "$#" -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
if [ ! -d exam-data ]; then echo 'Error: exam-data directory missing' >&2; exit 2; fi
COUNT=0
TOTAL=0
while IFS= read -r -d '' LOG; do
    LINES=$(wc -l < "$LOG") || exit 2
    printf '%s | lines: %s\n' "$LOG" "$LINES"
    COUNT=$((COUNT + 1))
    TOTAL=$((TOTAL + LINES))
done < <(find exam-data -maxdepth 3 -type f -name '*.log' -print0)
FIND_PID=$!
wait "$FIND_PID" || exit 2
printf 'Logs found: %s\nTotal lines: %s\n' "$COUNT" "$TOTAL"
