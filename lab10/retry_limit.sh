#!/bin/bash
set -o pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
require_directory case
CASE_ROOT=$(cd case && pwd -P) || exit 2
ATTEMPTS=0
MAX_ATTEMPTS=3
VALID=0
while [ "$VALID" -eq 0 ] && [ "$ATTEMPTS" -lt "$MAX_ATTEMPTS" ]; do
    if ! read -r -p "Enter a file inside case/ to identify: " TARGET_INPUT; then
        echo "Input ended before a valid file was supplied." >&2
        exit 1
    fi
    TARGET="case/$TARGET_INPUT"
    ATTEMPTS=$((ATTEMPTS + 1))
    if [ -f "$TARGET" ] && [ -r "$TARGET" ]; then
        RESOLVED=$(realpath -e -- "$TARGET") || exit 2
        if [[ "$RESOLVED" == "$CASE_ROOT/"* ]]; then VALID=1; break; fi
    fi
    printf '  %q is not a readable regular file inside case/ (%s/%s attempts used)\n' "$TARGET" "$ATTEMPTS" "$MAX_ATTEMPTS"
done
if [ "$VALID" -eq 1 ]; then
    TYPE=$(file -b -- "$TARGET") || die "cannot identify '$TARGET'"
    printf '%q: %s\n' "$TARGET" "$TYPE"
else echo "Too many failed attempts." >&2; exit 1; fi
