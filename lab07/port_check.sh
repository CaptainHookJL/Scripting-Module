#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then echo "Error: cannot read '$1'" >&2; exit 2; fi
CONF=$1
PORT=$(awk -F= '$1=="port" {sub(/\r$/, "", $2); print $2; exit}' "$CONF") || exit 2
if [ -z "$PORT" ]; then echo "$CONF: no port configured"
elif ! [[ "$PORT" =~ ^[0-9]+$ ]]; then echo "Error: $CONF: non-numeric port '$PORT'" >&2; exit 2
else
    PORT=$(printf '%s' "$PORT" | sed 's/^0*//'); PORT=${PORT:-0}
    if [ ${#PORT} -gt 5 ] || [ "$PORT" -gt 65535 ]; then echo "Error: $CONF: port outside 0-65535" >&2; exit 2
    elif [ "$PORT" -lt 1024 ]; then echo "$CONF: port $PORT is privileged (below 1024)"
    else echo "$CONF: port $PORT is unprivileged"; fi
fi
