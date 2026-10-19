#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -gt 1 ]; then echo "Usage: $0 [all|disabled|security]" >&2; exit 1; fi
MODE=${1:-all}
if [ "$MODE" != all ] && [ "$MODE" != disabled ] && [ "$MODE" != security ]; then
    echo "Usage: $0 [all|disabled|security]" >&2; exit 1
fi
require_file intel/users.csv
FIRST_LINE=1
while IFS=',' read -r USERNAME ROLE STATUS DEPT || [ -n "$USERNAME$ROLE$STATUS$DEPT" ]; do
    if [ "$FIRST_LINE" -eq 1 ]; then FIRST_LINE=0; continue; fi
    DEPT=${DEPT%$'\r'}
    [ -z "$USERNAME" ] && continue
    if [ "$MODE" = disabled ] && [ "$STATUS" != disabled ]; then continue; fi
    if [ "$MODE" = security ] && [ "$DEPT" != Security ]; then continue; fi
    printf 'User: %s | role: %s | status: %s | dept: [%s]\n' "$USERNAME" "$ROLE" "$STATUS" "$DEPT"
done < intel/users.csv
