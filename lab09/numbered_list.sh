#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case/configs
require_directory case/logs
INDEX=1
for FILE in case/configs/*.conf case/logs/*.log; do
    [ -f "$FILE" ] || continue
    echo "File #$INDEX: $FILE"
    INDEX=$((INDEX + 1))
done
