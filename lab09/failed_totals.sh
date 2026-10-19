#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

load_logs
TOTAL=0
for LOGFILE in "${LOGFILES[@]}"; do
    COUNT=$(count_lines -F -- 'Failed password' "$LOGFILE") || die "cannot search '$LOGFILE'"
    echo "$LOGFILE: $COUNT failed logins"
    TOTAL=$((TOTAL + COUNT))
done
echo "TOTAL: $TOTAL"
