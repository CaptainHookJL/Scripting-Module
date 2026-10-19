#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
require_directory case
require_file intel/iocs.txt
LOGS_SCANNED=0
TOTAL_MATCHES=0
MAX_MATCHES=3
while IFS= read -r -d '' LOGFILE; do
    require_file "$LOGFILE"
    LINES=$(wc -l < "$LOGFILE") || die "cannot count '$LOGFILE'"
    FAILED=$(count_failed "$LOGFILE") || die "cannot count failed logins"
    MATCHES=0
    printf 'File: %q\n' "$LOGFILE"
    while IFS= read -r INDICATOR || [ -n "$INDICATOR" ]; do
        INDICATOR=${INDICATOR%$'\r'}
        [ -z "$INDICATOR" ] && continue
        if indicator_matches "$INDICATOR" "$LOGFILE"; then
            MATCHES=$((MATCHES + 1))
            printf '  MATCH: %s\n' "$INDICATOR"
            if [ "$MATCHES" -ge "$MAX_MATCHES" ]; then
                echo "  Stopped early after $MAX_MATCHES IOC matches."
                break
            fi
        fi
    done < intel/iocs.txt
    echo "  Total lines: $LINES"
    echo "  Failed logins: $FAILED"
    echo "  IOC matches: $MATCHES"
    echo
    LOGS_SCANNED=$((LOGS_SCANNED + 1))
    TOTAL_MATCHES=$((TOTAL_MATCHES + MATCHES))
done < <(find case -type f -name '*.log' -print0)
FIND_PID=$!
wait "$FIND_PID" || die "recursive search failed"
[ "$LOGS_SCANNED" -gt 0 ] || die "no .log files found"
echo "Logs scanned: $LOGS_SCANNED"
echo "Total IOC matches (capped at $MAX_MATCHES per log): $TOTAL_MATCHES"
if [ "$TOTAL_MATCHES" -gt 0 ]; then echo "Investigation required: yes"; exit 1
else echo "Investigation required: no IOC matches in the configured list"; exit 0; fi
