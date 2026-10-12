#!/bin/bash

if grep -q sqlmap case/logs/access.log; then echo "Scanning tool activity detected"
else
    STATUS=$?
    if [ "$STATUS" -gt 1 ]; then exit "$STATUS"; fi
    echo "No scanning tool activity"
fi
