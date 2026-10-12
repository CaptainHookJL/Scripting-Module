#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <logfile>" >&2; exit 1; fi
LOGFILE=$1
if [ ! -f "$LOGFILE" ]; then echo "Error: file '$LOGFILE' not found" >&2; exit 2; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: file '$LOGFILE' cannot be read" >&2; exit 3; fi
LINE_COUNT=$(wc -l < "$LOGFILE") || exit 3
WORD_COUNT=$(wc -w < "$LOGFILE") || exit 3
CHAR_COUNT=$(wc -c < "$LOGFILE") || exit 3
FIRST_LINE=$(head -n 1 -- "$LOGFILE") || exit 3
LAST_LINE=$(tail -n 1 -- "$LOGFILE") || exit 3
LONGEST_LINE=$(awk 'length > max {max=length} END {print max+0}' "$LOGFILE") || exit 3
FAILED=$(grep -c 'Failed password' -- "$LOGFILE")
STATUS=$?
if [ "$STATUS" -gt 1 ]; then exit "$STATUS"; fi
echo "Log file        : $LOGFILE"
echo "Total lines     : $LINE_COUNT"
echo "Total words     : $WORD_COUNT"
echo "Total characters: $CHAR_COUNT"
echo "First line      : $FIRST_LINE"
echo "Last line       : $LAST_LINE"
echo "Longest line    : $LONGEST_LINE characters"
echo "Failed logins   : $FAILED"
read -r -p "Enter a keyword to search for (or press Enter to skip): " KEYWORD
if [ -n "$KEYWORD" ]; then
    MATCH_COUNT=$(grep -c -- "$KEYWORD" "$LOGFILE")
    STATUS=$?
    echo "grep exit code: $STATUS"
    if [ "$STATUS" -gt 1 ]; then exit "$STATUS"; fi
    if [ "$MATCH_COUNT" -eq 0 ]; then echo "No matches found."
    else echo "Lines containing '$KEYWORD': $MATCH_COUNT"; fi
fi
exit 0
