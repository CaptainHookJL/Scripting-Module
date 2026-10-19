#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
require_directory case
# Deliberately demonstrate the pipeline subshell; do not use this for a real total.
shopt -u lastpipe
COUNT=0
find case -type f -name '*.log' -print0 |
while IFS= read -r -d '' LOGFILE; do
    COUNT=$((COUNT + 1))
    echo "inside the loop: COUNT=$COUNT"
done
STATUS=$?
[ "$STATUS" -eq 0 ] || die "recursive search failed"
echo "after the loop:  COUNT=$COUNT"
