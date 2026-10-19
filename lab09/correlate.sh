#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

load_logs
load_indicators
for INDICATOR in "${INDICATORS[@]}"; do
    SOURCES=0
    WHERE=""
    for LOGFILE in "${LOGFILES[@]}"; do
        COUNT=$(count_lines -wF -- "$INDICATOR" "$LOGFILE") || die "cannot search '$LOGFILE'"
        if [ "$COUNT" -gt 0 ]; then
            SOURCES=$((SOURCES + 1))
            WHERE="$WHERE $(basename -- "$LOGFILE")"
        fi
    done
    echo "$INDICATOR: seen in $SOURCES log(s):$WHERE"
done
