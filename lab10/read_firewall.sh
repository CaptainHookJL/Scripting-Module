#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
require_file case/logs/firewall.log
declare -A PORT_COUNTS=([22]=0 [80]=0 [443]=0 [3389]=0)
BLOCKED=0
while read -r ACTION SRC ARROW DST || [ -n "$ACTION$SRC$ARROW$DST" ]; do
    ACTION=${ACTION%$'\r'}
    [ -z "$ACTION" ] && continue
    DST=${DST%$'\r'}
    [ "$ARROW" = '->' ] && [ -n "$SRC" ] && [[ "$DST" == *:* ]] || die "invalid firewall record"
    PORT=${DST##*:}
    [[ "$PORT" =~ ^[0-9]+$ ]] || die "invalid destination port"
    [ "$ACTION" = BLOCK ] || continue
    printf 'BLOCK from %s to port %s\n' "$SRC" "$PORT"
    PORT_COUNTS["$PORT"]=$(( ${PORT_COUNTS["$PORT"]:-0} + 1 ))
    BLOCKED=$((BLOCKED + 1))
done < case/logs/firewall.log
echo "Blocked records per destination port:"
while IFS= read -r PORT; do
    echo "  port $PORT: ${PORT_COUNTS[$PORT]}"
done < <(printf '%s\n' "${!PORT_COUNTS[@]}" | sort -n)
echo "Total BLOCK records: $BLOCKED"
