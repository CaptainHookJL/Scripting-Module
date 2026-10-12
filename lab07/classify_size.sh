#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then echo "Error: cannot read '$1'" >&2; exit 2; fi
SMALL_LIMIT=10
MEDIUM_LIMIT=70
FILE=$1
LINES=$(wc -l < "$FILE") || exit 2
if [ "$LINES" -eq 0 ]; then TIER=EMPTY
elif [ "$LINES" -lt "$SMALL_LIMIT" ]; then TIER=SMALL
elif [ "$LINES" -lt "$MEDIUM_LIMIT" ]; then TIER=MEDIUM
else TIER=LARGE; fi
echo "$FILE is $TIER ($LINES lines)"
