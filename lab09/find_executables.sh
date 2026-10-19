#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case
for FILE in case/*/*; do
    [ -f "$FILE" ] || continue
    require_file "$FILE"
    TYPE=$(file -b -- "$FILE") || die "cannot identify '$FILE'"
    if [[ "$TYPE" == ELF* ]]; then echo "EXECUTABLE CONTENT: $FILE ($TYPE)"; fi
done
