#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_file case/logs/auth.log
load_indicators
for INDICATOR in "${INDICATORS[@]}"; do
    COUNT=$(count_lines -wF -- "$INDICATOR" case/logs/auth.log) || die "cannot search auth.log"
    if [ "$COUNT" -gt 0 ]; then echo "MATCH   : $INDICATOR found in auth.log"
    else echo "no match: $INDICATOR"; fi
done
