#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <failed_attempt_count>" >&2; exit 1; fi
if ! [[ "$1" =~ ^[0-9]+$ ]]; then echo "Error: count must be a non-negative integer" >&2; exit 2; fi
# Strip leading zeros before comparisons; reject integers outside Bash's safe range.
COUNT=$(printf '%s' "$1" | sed 's/^0*//')
COUNT=${COUNT:-0}
if [ ${#COUNT} -gt 18 ]; then echo "Error: count is too large" >&2; exit 2; fi
if [ "$COUNT" -eq 0 ]; then echo "Risk: NONE (no failed attempts)"
elif [ "$COUNT" -lt 5 ]; then echo "Risk: LOW ($COUNT failed attempts)"
elif [ "$COUNT" -lt 15 ]; then echo "Risk: MEDIUM ($COUNT failed attempts)"
elif [ "$COUNT" -lt 30 ]; then echo "Risk: HIGH ($COUNT failed attempts)"
else echo "Risk: CRITICAL ($COUNT failed attempts)"; fi
