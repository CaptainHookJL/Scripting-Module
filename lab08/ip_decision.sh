#!/bin/bash
set -o pipefail

if [ $# -ne 1 ] || [ -z "$1" ]; then echo "Usage: $0 <ip_address>" >&2; exit 1; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 4
bash "$SCRIPT_DIR/check_ip.sh" case/logs/firewall.log "$1" > /dev/null
RESULT=$?
if [ "$RESULT" -eq 0 ]; then
    echo "Decision: $1 is recorded in the firewall log — check what action was taken."
    grep -wF -- "$1" case/logs/firewall.log || exit 4
elif [ "$RESULT" -eq 3 ]; then echo "Decision: no record of $1 in this collected firewall log."
else echo "Error: could not complete the check (exit code $RESULT)." >&2; exit "$RESULT"; fi
