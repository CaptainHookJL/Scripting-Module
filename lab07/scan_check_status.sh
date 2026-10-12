#!/bin/bash

grep -q sqlmap case/logs/access.log
STATUS=$?
if [ "$STATUS" -eq 0 ]; then echo "Scanning tool activity detected"
elif [ "$STATUS" -eq 1 ]; then echo "No scanning tool activity"
else exit "$STATUS"; fi
