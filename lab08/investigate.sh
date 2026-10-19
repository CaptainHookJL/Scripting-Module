#!/bin/bash
set -o pipefail

if [ $# -ne 2 ]; then echo "Usage: $0 <logfile> <ip_or_username>" >&2; exit 1; fi
LOGFILE=$1
TERM_ARG=$2
if [ ! -e "$LOGFILE" ]; then echo "Error: '$LOGFILE' does not exist" >&2; exit 2; fi
if [ ! -f "$LOGFILE" ]; then echo "Error: '$LOGFILE' is not a regular file" >&2; exit 3; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: '$LOGFILE' is unreadable" >&2; exit 4; fi
if [ -z "$TERM_ARG" ]; then echo "Error: search term is empty" >&2; exit 5; fi
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 7
if printf '%s\n' "$TERM_ARG" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then
    for SOURCE in case/logs/firewall.log intel/iocs.txt; do
        if [ ! -f "$SOURCE" ] || [ ! -r "$SOURCE" ]; then echo "Error: cannot read '$SOURCE'" >&2; exit 7; fi
    done
    COUNT=$(grep -cwF -- "$TERM_ARG" "$LOGFILE")
    STATUS=$?
    if [ "$STATUS" -gt 1 ]; then exit 7; fi
    FAILED=$(awk -v ip="$TERM_ARG" '/Failed password/ {
        for(i=1;i<NF;i++) if($i=="from" && $(i+1)==ip) {count++; break}
    } END {print count+0}' "$LOGFILE") || exit 7
    echo "IP: $TERM_ARG"
    echo "Matching lines: $COUNT"
    echo "Failed password events: $FAILED"
    bash "$SCRIPT_DIR/../lab07/risk_level.sh" "$FAILED" || exit 7
    FIREWALL=$(grep -wF -- "$TERM_ARG" case/logs/firewall.log)
    STATUS=$?
    if [ "$STATUS" -gt 1 ]; then exit 7; fi
    if [ -n "$FIREWALL" ]; then echo "Firewall records:"; printf '%s\n' "$FIREWALL"
    else echo "Firewall: no record in the collected log"; fi
    if grep -qxF -- "$TERM_ARG" intel/iocs.txt; then echo "IOC list: listed"
    else
        STATUS=$?
        if [ "$STATUS" -gt 1 ]; then exit 7; fi
        echo "IOC list: not listed"
    fi
else
    for SOURCE in intel/users.csv case/backups/users.old; do
        if [ ! -f "$SOURCE" ] || [ ! -r "$SOURCE" ]; then echo "Error: cannot read '$SOURCE'" >&2; exit 7; fi
    done
    USERNAME=$TERM_ARG
STATS=$(awk -v name="$USERNAME" '
    /Failed password for / || /Accepted password for / {
        for (i=1;i<NF;i++) if ($i=="for") {
            j=i+1; if ($j=="invalid" && $(j+1)=="user") j+=2
            if ($j==name) {if ($0 ~ /Failed password/) failed++; else accepted++}
            break
        }
    }
    END {print failed+0, accepted+0}
' "$LOGFILE") || exit 4
read -r FAILS ACCEPTS <<< "$STATS"
ACTIVITY=$(awk -v name="$USERNAME" '
    {for(i=1;i<NF;i++) if($i=="for") {
        j=i+1; if($j=="invalid" && $(j+1)=="user") j+=2
        if($j==name) count++; break
    }} END {print count+0}
' "$LOGFILE") || exit 4
    COUNT=$ACTIVITY
    echo "Username: $USERNAME"
    echo "Matching activity lines: $COUNT"
    echo "Failed logins: $FAILS"
    echo "Accepted logins: $ACCEPTS"
    if awk -F, -v name="$USERNAME" 'NR>1 && $1==name {found=1} END {exit !found}' intel/users.csv; then
        echo "Account source: CURRENT"
    elif grep -Fxq -- "$USERNAME" case/backups/users.old; then echo "Account source: LEGACY"
    else echo "Account source: UNKNOWN"; fi
fi
if [ "$COUNT" -gt 0 ]; then exit 0; else echo "Not found in the selected log"; exit 6; fi
