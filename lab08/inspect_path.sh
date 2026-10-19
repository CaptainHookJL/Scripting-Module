#!/bin/bash
set -o pipefail

if [ $# -ne 1 ] || [ -z "$1" ]; then echo "Usage: $0 <path>" >&2; exit 1; fi
TARGET=$1
if [ ! -e "$TARGET" ]; then echo "Error: $TARGET does not exist" >&2; exit 2
elif [ -d "$TARGET" ]; then echo "$TARGET is a directory"
elif [ -f "$TARGET" ]; then
    echo "$TARGET is a regular file"
    if [ ! -r "$TARGET" ]; then echo "Warning: $TARGET is not readable" >&2; exit 3
    elif [ -s "$TARGET" ]; then
        BYTES=$(wc -c < "$TARGET") || exit 3
        echo "  and it is not empty ($BYTES bytes)"
    else echo "  but it is empty"; fi
else echo "$TARGET exists but is neither a regular file nor a directory"; fi
