#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_directory case/evidence
require_directory case/scripts
require_directory case/logs
load_indicators
FILES_SURVEYED=0
FILES_FLAGGED=0
TOTAL_IOC_MATCHES=0
TOTAL_IOC_LINES=0
for FILE in case/evidence/* case/scripts/* case/logs/*; do
    [ -f "$FILE" ] || continue
    require_file "$FILE"
    BYTES=$(wc -c < "$FILE") || die "cannot measure '$FILE'"
    TYPE=$(file -b -- "$FILE") || die "cannot identify '$FILE'"
    HASH=$(sha256sum -- "$FILE" | awk '{print $1}') || die "cannot hash '$FILE'"
    FILES_SURVEYED=$((FILES_SURVEYED + 1))
    echo "File: $FILE"
    echo "  Size: $BYTES bytes"
    echo "  Type: $TYPE"
    if [[ "$TYPE" == *text* ]]; then
        LINES=$(wc -l < "$FILE") || die "cannot count '$FILE'"
        echo "  Lines: $LINES"
    fi
    echo "  SHA-256: $HASH"
    classify_type "$FILE" "$TYPE"
    if [ "$MARK" = '!!' ]; then
        FILES_FLAGGED=$((FILES_FLAGGED + 1))
        echo "  !! Extension/type disagreement: expected $EXPECT"
    elif [ "$MARK" = '??' ]; then echo "  ?? No extension expectation"
    else echo "  OK Extension/type check"; fi
    if [[ "$FILE" == *.log ]]; then
        DISTINCT=0
        INDICATOR_LINES=0
        for INDICATOR in "${INDICATORS[@]}"; do
            COUNT=$(count_lines -wF -- "$INDICATOR" "$FILE") || die "cannot search '$FILE'"
            if [ "$COUNT" -gt 0 ]; then
                DISTINCT=$((DISTINCT + 1))
                INDICATOR_LINES=$((INDICATOR_LINES + COUNT))
            fi
        done
        TOTAL_IOC_MATCHES=$((TOTAL_IOC_MATCHES + DISTINCT))
        TOTAL_IOC_LINES=$((TOTAL_IOC_LINES + INDICATOR_LINES))
        echo "  Distinct IOC matches: $DISTINCT"
        echo "  Indicator lines: $INDICATOR_LINES"
    fi
    echo
done
echo "Files surveyed: $FILES_SURVEYED"
echo "Files flagged: $FILES_FLAGGED"
echo "Total IOC matches (sum of distinct indicators per log): $TOTAL_IOC_MATCHES"
echo "Total indicator lines (sum per indicator, per log): $TOTAL_IOC_LINES"
