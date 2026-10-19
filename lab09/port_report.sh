#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case/configs
REPORT=""
for CONF in case/configs/*.conf case/backups/config.old; do
    [ -f "$CONF" ] || continue
    require_file "$CONF"
    PORT=$(awk -F= '$1=="port" {sub(/\r$/, "", $2); print $2; exit}' "$CONF") || die "cannot read '$CONF'"
    DEBUG=$(awk -F= '$1=="debug" {sub(/\r$/, "", $2); print $2; exit}' "$CONF") || die "cannot read '$CONF'"
    PORT=${PORT:-'(none)'}
    DEBUG=${DEBUG:-'(none)'}
    REPORT="${REPORT}${CONF}: port ${PORT}; debug ${DEBUG}"$'\n'
done
echo "Configured ports and debug settings:"
printf '%s' "$REPORT"
