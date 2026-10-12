#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then echo "Error: cannot read '$1'" >&2; exit 2; fi
CONF=$1
VALUE=$(awk -F= '$1=="debug" {sub(/\r$/, "", $2); print $2; exit}' "$CONF") || exit 2
VALUE_LOWER="${VALUE,,}"
if [ -z "$VALUE" ]; then echo "$CONF: no debug setting"
elif [ "$VALUE_LOWER" = true ] || [ "$VALUE_LOWER" = yes ]; then
    echo "$CONF: WARNING - debug mode is ON"
elif [ "$VALUE_LOWER" = false ] || [ "$VALUE_LOWER" = no ]; then
    echo "$CONF: debug mode is off"
else echo "$CONF: unexpected debug value '$VALUE'"; fi
