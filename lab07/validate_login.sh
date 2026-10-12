#!/bin/bash

read -r -p "Enter a username: " USERNAME
if [ -z "$USERNAME" ]; then echo "Error: no username entered" >&2; exit 1; fi
for SOURCE in intel/users.csv case/backups/users.old case/logs/auth.log case/evidence/passwords.txt; do
    if [ ! -f "$SOURCE" ] || [ ! -r "$SOURCE" ]; then echo "Error: cannot read '$SOURCE'" >&2; exit 4; fi
done
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 4
ROW=$(awk -F, -v name="$USERNAME" 'NR>1 && $1==name {sub(/\r$/, ""); print; exit}' intel/users.csv) || exit 4
if [ -n "$ROW" ]; then
    CATEGORY=CURRENT; RESULT=0
    IFS=, read -r NAME ROLE STATUS DEPARTMENT <<< "$ROW"
    echo "$USERNAME: CURRENT account (role: $ROLE; status: $STATUS)"
elif grep -Fxq -- "$USERNAME" case/backups/users.old; then
    CATEGORY=LEGACY; RESULT=2
    echo "$USERNAME: LEGACY account (only in the old backup list)"
else CATEGORY=UNKNOWN; RESULT=3; echo "$USERNAME: UNKNOWN account (in neither list)"; fi
FAILED=$(grep -Fc -- "Failed password for $USERNAME " case/logs/auth.log)
GREP_STATUS=$?
if [ "$GREP_STATUS" -gt 1 ]; then exit 4; fi
ACCEPTED=$(grep -Fc -- "Accepted password for $USERNAME " case/logs/auth.log)
GREP_STATUS=$?
if [ "$GREP_STATUS" -gt 1 ]; then exit 4; fi
echo "Failed logins: $FAILED"
echo "Accepted logins: $ACCEPTED"
bash "$SCRIPT_DIR/risk_level.sh" "$FAILED" || exit 4
if [ "$CATEGORY" = CURRENT ]; then
    if [ "$STATUS" = disabled ] && [ "$ACCEPTED" -gt 0 ]; then
        echo "WARNING: disabled current account has accepted logins."
    fi
    if [ "$ACCEPTED" -gt 0 ] && awk -F: -v name="$USERNAME" '$1==name {found=1} END {exit !found}' case/evidence/passwords.txt; then
        echo "WARNING: current account has plaintext credentials in workstation evidence and accepted logins."
    fi
elif [ "$FAILED" -gt 0 ]; then
    echo "WARNING: $CATEGORY account was targeted; attacker is guessing account names."
fi
exit "$RESULT"
