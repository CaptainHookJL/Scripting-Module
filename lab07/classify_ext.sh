#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
FILE=$1
EXT="${FILE##*.}"
if [ "$EXT" = log ]; then LABEL="log file"
elif [ "$EXT" = conf ]; then LABEL="configuration file"
elif [ "$EXT" = txt ] || [ "$EXT" = md ]; then LABEL="text document"
elif [ "$EXT" = sh ] || [ "$EXT" = py ]; then LABEL=script
else LABEL="unrecognised extension '$EXT'"; fi
echo "$FILE : $LABEL"
