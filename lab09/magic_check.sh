#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case/evidence
require_directory case/scripts
for FILE in case/evidence/* case/scripts/*; do
    [ -f "$FILE" ] || continue
    require_file "$FILE"
    TYPE=$(file -b -- "$FILE") || die "cannot identify '$FILE'"
    classify_type "$FILE" "$TYPE"
    if [ "$MARK" = '??' ]; then echo "?? $FILE — no expectation for this extension; detected: $TYPE"
    elif [ "$MARK" = OK ]; then echo "OK $FILE — $TYPE"
    else echo "!! $FILE — expected $EXPECT, detected: $TYPE"; fi
done
