#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case/evidence
COUNT=0
for FILE in case/evidence/*; do
    [ -f "$FILE" ] || continue
    require_file "$FILE"
    sha256sum -- "$FILE" || die "cannot hash '$FILE'"
    COUNT=$((COUNT + 1))
done
[ "$COUNT" -gt 0 ] || die "no regular evidence files to hash"
