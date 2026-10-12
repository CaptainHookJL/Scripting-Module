#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
FILE=$1
if [ -f "$FILE" ]; then
    echo "$FILE exists."
    LINES=$(wc -l < "$FILE") || exit 2
    if [ "$LINES" -eq 0 ]; then echo "  ...but it has no lines."
    else echo "  ...and has $LINES lines."; fi
else echo "$FILE does not exist — skipping the line count entirely."; fi
