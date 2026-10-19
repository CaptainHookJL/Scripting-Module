#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -gt 1 ]; then echo "Usage: $0 [logfile]" >&2; exit 1; fi
LOG=${1:-case/logs/firewall.log}
require_file "$LOG"
require_file intel/iocs.txt
FOUND=0
while IFS= read -r INDICATOR || [ -n "$INDICATOR" ]; do
    INDICATOR=${INDICATOR%$'\r'}
    [ -z "$INDICATOR" ] && continue
    if indicator_matches "$INDICATOR" "$LOG"; then
        printf 'First match in %q: %s — stopping search.\n' "$LOG" "$INDICATOR"
        FOUND=1
        break
    fi
done < intel/iocs.txt
if [ "$FOUND" -eq 0 ]; then printf 'No IOC matches found in %q.\n' "$LOG"; fi
echo "Search finished."
