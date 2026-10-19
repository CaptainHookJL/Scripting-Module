#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_file case/logs/auth.log
load_indicators
ATTACKERS=$(awk '/Failed password/ {for(i=1;i<NF;i++) if($i=="from") print $(i+1)}' case/logs/auth.log | sort -u) || die "cannot enumerate SSH sources"
# Extracted addresses contain no whitespace; this deliberate word splitting is safe.
for IP in $ATTACKERS; do
    COUNT=$(awk -v ip="$IP" '/Failed password/ {for(i=1;i<NF;i++) if($i=="from" && $(i+1)==ip) {count++; break}} END {print count+0}' case/logs/auth.log) || die "cannot count SSH failures"
    if grep -qxF -- "$IP" intel/iocs.txt; then
        echo "$IP ($COUNT failures): already in IOC list"
    else
        STATUS=$?
        [ "$STATUS" -eq 1 ] || die "cannot search indicator list"
        echo "$IP ($COUNT failures): NOT in IOC list — candidate for new indicator"
    fi
done
