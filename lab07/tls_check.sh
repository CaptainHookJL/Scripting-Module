#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then echo "Error: cannot read '$1'" >&2; exit 2; fi
CONF=$1
VALUE=$(awk -F= '$1=="tls" {sub(/\r$/, "", $2); print $2; exit}' "$CONF") || exit 2
VALUE_LOWER="${VALUE,,}"
if [ -z "$VALUE" ]; then echo "$CONF: no tls setting"
elif [ "$VALUE_LOWER" = true ] || [ "$VALUE_LOWER" = yes ]; then
    echo "$CONF: TLS is enabled"
elif [ "$VALUE_LOWER" = false ] || [ "$VALUE_LOWER" = no ]; then
    echo "$CONF: WARNING - TLS is disabled"
else echo "$CONF: unexpected tls value '$VALUE'"; fi
