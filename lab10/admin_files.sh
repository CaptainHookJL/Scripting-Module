#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -gt 1 ] || { [ $# -eq 1 ] && [ -z "$1" ]; }; then echo "Usage: $0 [keyword]" >&2; exit 1; fi
KEYWORD=${1:-admin}
require_directory case
while IFS= read -r -d '' FILE; do
    require_file "$FILE"
    COUNT=$(grep -cF -- "$KEYWORD" "$FILE")
    STATUS=$?
    [ "$STATUS" -le 1 ] || die "cannot search '$FILE'"
    printf '%q mentions %s (%s line(s))\n' "$FILE" "$KEYWORD" "$COUNT"
done < <(grep -rlZF -- "$KEYWORD" case)
GREP_PID=$!
wait "$GREP_PID"
STATUS=$?
[ "$STATUS" -le 1 ] || die "recursive keyword search failed"
