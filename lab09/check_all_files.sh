#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

for FILE in case/logs/auth.log case/logs/access.log case/logs/firewall.log case/logs/missing.log; do
    echo "Checking $FILE..."
    if [ -f "$FILE" ]; then
        require_file "$FILE"
        LINES=$(wc -l < "$FILE") || die "cannot count '$FILE'"
        echo "  exists, $LINES lines"
    else echo "  MISSING"; fi
done
