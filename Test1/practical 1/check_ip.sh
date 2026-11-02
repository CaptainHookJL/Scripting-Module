#!/bin/bash
if [ "$#" -ne 1 ] || [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Usage: $0 <IPv4 address>" >&2; exit 1
fi
IP=$1
AUTH=exam-data/case/logs/auth.log
FW=exam-data/case/logs/firewall.log
IOC=exam-data/intel/iocs.txt
for FILE in "$AUTH" "$FW" "$IOC"; do
    if [ ! -f "$FILE" ] || [ ! -r "$FILE" ]; then echo "Error: cannot read $FILE" >&2; exit 2; fi
done
# The address following the SSH 'from' field must match exactly.
FAILED=$(awk -v ip="$IP" '/Failed password/ {for(i=1;i<NF;i++) if($i=="from" && $(i+1)==ip) {n++; break}} END {print n+0}' "$AUTH") || exit 2
ACCEPTED=$(awk -v ip="$IP" '/Accepted password/ {for(i=1;i<NF;i++) if($i=="from" && $(i+1)==ip) {n++; break}} END {print n+0}' "$AUTH") || exit 2
if [ "$FAILED" -eq 0 ]; then RISK=NONE
elif [ "$FAILED" -le 4 ]; then RISK=LOW
elif [ "$FAILED" -lt 9 ]; then RISK=MEDIUM
else RISK=HIGH; fi
printf 'IP : %s\nFailed : %s\nAccepted : %s\nRisk : %s\n' "$IP" "$FAILED" "$ACCEPTED" "$RISK"
if grep -qxF -- "$IP" "$IOC"; then echo 'IOC : yes'
else STATUS=$?; [ "$STATUS" -eq 1 ] || exit 2; echo 'IOC : no'; fi
# IPv4 punctuation is literal, and adjacent digits/dots cannot extend a match.
PATTERN="(^|[^0-9.])${IP//./\\.}([^0-9.]|$)"
grep -E -- "$PATTERN" "$FW"
STATUS=$?
if [ "$STATUS" -eq 1 ]; then echo 'Firewall : no entries'
elif [ "$STATUS" -ne 0 ]; then exit 2; fi
if [ "$FAILED" -gt 0 ] && [ "$ACCEPTED" -gt 0 ]; then
    echo 'WARNING: successful login after failed attempts'
fi
FOUND=0
for FILE in exam-data/case/logs/*; do
    [ -f "$FILE" ] || continue
    grep -E -- "$PATTERN" "$FILE" > /dev/null
    STATUS=$?
    if [ "$STATUS" -eq 0 ]; then FOUND=1
    elif [ "$STATUS" -gt 1 ]; then exit 2; fi
done
[ "$FOUND" -eq 1 ] && exit 0
exit 3
