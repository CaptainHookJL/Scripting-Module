#!/bin/bash
set -o pipefail

if [ $# -ne 1 ] || [ -z "$1" ]; then echo "Usage: $0 <path>" >&2; exit 1; fi
FILE=$1
if [ ! -f "$FILE" ]; then echo "$FILE: not a regular file" >&2; exit 2; fi
if [ ! -r "$FILE" ]; then echo "$FILE: not readable" >&2; exit 3; fi
FIRST_TWO=$(head -c 2 -- "$FILE") || exit 3
if [ "$FIRST_TWO" = '#!' ] && [ ! -x "$FILE" ]; then
    echo "$FILE: has an interpreter line ($(head -n 1 -- "$FILE")) but is NOT executable"
elif [ "$FIRST_TWO" = '#!' ]; then echo "$FILE: executable script ($(head -n 1 -- "$FILE"))"
else echo "$FILE: no interpreter line"; fi
