#!/bin/bash
if [ "$#" -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
IOC=exam-data/intel/iocs.txt
if [ ! -r "$IOC" ]; then echo "Error: cannot read $IOC" >&2; exit 2; fi
mapfile -t INDICATORS < "$IOC" || exit 2
LOGS=(exam-data/case/logs/*.log)
if [ ! -f "${LOGS[0]}" ]; then echo 'Error: no logs found' >&2; exit 2; fi
TOTAL=0
for INDICATOR in "${INDICATORS[@]}"; do
    INDICATOR=${INDICATOR%$'\r'}
    [ -n "$INDICATOR" ] || continue
    SEEN=0
    for LOG in "${LOGS[@]}"; do
        COUNT=$(grep -cwF -- "$INDICATOR" "$LOG"); STATUS=$?
        [ "$STATUS" -le 1 ] || exit 2
        if [ "$COUNT" -gt 0 ]; then
            printf '%s | %s | lines: %s\n' "$INDICATOR" "${LOG##*/}" "$COUNT"
            SEEN=$((SEEN + 1))
            TOTAL=$((TOTAL + COUNT))
        fi
    done
    printf '%s | logs: %s\n' "$INDICATOR" "$SEEN"
done
printf 'Total matching lines: %s\n' "$TOTAL"
FILES=0
for FILE in exam-data/case/evidence/*; do
    [ -f "$FILE" ] || continue
    FILES=$((FILES + 1))
    HASH=$(md5sum < "$FILE") || exit 2
    HASH=${HASH%% *}
    if grep -qxF -- "$HASH" "$IOC"; then printf 'KNOWN BAD: %s\n' "$FILE"
    else STATUS=$?; [ "$STATUS" -eq 1 ] || exit 2; printf 'clean : %s\n' "$FILE"; fi
done
if [ "$FILES" -eq 0 ]; then echo 'Error: no evidence files' >&2; exit 2; fi
