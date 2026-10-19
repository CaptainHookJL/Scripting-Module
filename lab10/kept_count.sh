#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
require_directory case
COUNT=0
TOTAL_LINES=0
while IFS= read -r -d '' LOGFILE; do
    require_file "$LOGFILE"
    LINES=$(wc -l < "$LOGFILE") || die "cannot count '$LOGFILE'"
    COUNT=$((COUNT + 1))
    TOTAL_LINES=$((TOTAL_LINES + LINES))
    printf '%q: %s lines\n' "$LOGFILE" "$LINES"
done < <(find case -type f -name '*.log' -print0)
FIND_PID=$!
wait "$FIND_PID" || die "recursive search failed"
[ "$COUNT" -gt 0 ] || die "no .log files found"
echo "after the loop: COUNT=$COUNT"
echo "Total lines: $TOTAL_LINES"
