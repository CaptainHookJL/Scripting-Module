#!/bin/bash
set -o pipefail

if [ $# -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
source "$SCRIPT_DIR/lib/common.sh" || exit 2

require_file case/logs/access.log
load_indicators
CLIENTS=$(awk 'NF {print $1}' case/logs/access.log | sort -u) || die "cannot enumerate web clients"
for IP in $CLIENTS; do
    COUNT=$(awk -v ip="$IP" '$1==ip {count++} END {print count+0}' case/logs/access.log) || die "cannot count web requests"
    if grep -qxF -- "$IP" intel/iocs.txt; then
        echo "$IP ($COUNT requests): already in IOC list"
    else
        STATUS=$?
        [ "$STATUS" -eq 1 ] || die "cannot search indicator list"
        if [[ "$IP" == 192.168.* ]]; then SCOPE=internal; else SCOPE='outside the internal 192.168/16 range'; fi
        echo "$IP ($COUNT requests): NOT in IOC list — $SCOPE"
    fi
done
