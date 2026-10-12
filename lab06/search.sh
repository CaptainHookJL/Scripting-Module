#!/bin/bash

if [ $# -ne 2 ]; then echo "Usage: $0 <logfile> <keyword>" >&2; exit 2; fi
echo "Searching for '$2' in $1..."
grep -- "$2" "$1"
