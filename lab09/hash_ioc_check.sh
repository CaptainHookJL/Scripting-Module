#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case/evidence
load_indicators
for FILE in case/evidence/*; do
    [ -f "$FILE" ] || continue
    require_file "$FILE"
    HASH=$(md5sum -- "$FILE" | awk '{print $1}') || die "cannot hash '$FILE'"
    if grep -qxF -- "$HASH" intel/iocs.txt; then
        echo "HASH IOC MATCH: $FILE ($HASH)"
    else
        STATUS=$?
        [ "$STATUS" -eq 1 ] || die "cannot search indicator list"
        echo "no hash IOC match: $FILE"
    fi
done
