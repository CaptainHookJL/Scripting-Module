#!/bin/bash
if [ "$#" -ne 0 ]; then echo "Usage: $0 (no arguments)" >&2; exit 1; fi
CSV=exam-data/intel/users.csv
AUTH=exam-data/case/logs/auth.log
for FILE in "$CSV" "$AUTH"; do
    if [ ! -f "$FILE" ] || [ ! -r "$FILE" ]; then echo "Error: cannot read $FILE" >&2; exit 2; fi
done
FIRST=1
ACTIVE=1
DISABLED=0
while IFS=',' read -r USER ROLE STATUS DEPT || [ -n "$USER$ROLE$STATUS$DEPT" ]; do
    if [ "$FIRST" -eq 1 ]; then FIRST=0; continue; fi
    [ -n "$USER" ] || continue
    DEPT=${DEPT%$'\r'}
    LOGINS=$(awk -v user="$USER" '/Accepted password/ {for(i=1;i+3<=NF;i++) if($i=="Accepted" && $(i+1)=="password" && $(i+2)=="for" && $(i+3)==user) {n++; break}} END {print n+0}' "$AUTH") || exit 2
    printf '%s | %s | %s | %s | logins: %s\n' "$USER" "$ROLE" "$STATUS" "$DEPT" "$LOGINS"
    if [ "$STATUS" = active ]; then ACTIVE=$((ACTIVE + 1))
    elif [ "$STATUS" = disabled ]; then
        DISABLED=$((DISABLED + 1))
        if [ "$LOGINS" -gt 0 ]; then printf 'ALERT: disabled account %s has %s successful logins\n' "$USER" "$LOGINS"; fi
    fi
done < "$CSV"
printf 'Active accounts: %s\nDisabled accounts: %s\n' "$ACTIVE" "$DISABLED"
