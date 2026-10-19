#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -ne 1 ]; then echo "Usage: $0 <logfile>" >&2; exit 1; fi
LOGFILE=$1
require_file "$LOGFILE"
require_file intel/iocs.txt
MATCHES=0
NOT_FOUND=0
while IFS= read -r INDICATOR || [ -n "$INDICATOR" ]; do
    INDICATOR=${INDICATOR%$'\r'}
    [ -z "$INDICATOR" ] && continue
    if indicator_matches "$INDICATOR" "$LOGFILE"; then
        printf 'MATCH: %s\n' "$INDICATOR"
        MATCHES=$((MATCHES + 1))
    else NOT_FOUND=$((NOT_FOUND + 1)); fi
done < intel/iocs.txt
printf 'Total IOC matches in %q: %s\n' "$LOGFILE" "$MATCHES"
echo "Indicators not found: $NOT_FOUND"
