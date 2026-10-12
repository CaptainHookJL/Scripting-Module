#!/bin/bash

if [ $# -ne 1 ] || [ -z "$1" ]; then echo "Usage: $0 <username>" >&2; exit 1; fi
USERNAME=$1
for SOURCE in intel/users.csv case/backups/users.old; do
    if [ ! -f "$SOURCE" ] || [ ! -r "$SOURCE" ]; then echo "Error: cannot read '$SOURCE'" >&2; exit 4; fi
done
# Compare complete literal fields; a username must not become a regular expression.
if awk -F, -v name="$USERNAME" 'NR>1 && $1==name {found=1} END {exit !found}' intel/users.csv; then
    echo "$USERNAME: CURRENT account"
elif grep -Fxq -- "$USERNAME" case/backups/users.old; then
    echo "$USERNAME: LEGACY account (only in the old backup list)"
else echo "$USERNAME: UNKNOWN account (in neither list)"; fi
