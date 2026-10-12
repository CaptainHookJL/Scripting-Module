#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <integer>" >&2; exit 1; fi
if ! [[ "$1" =~ ^-?[0-9]+$ ]] || [ ${#1} -gt 18 ]; then echo "Error: expected an integer" >&2; exit 2; fi
COUNT=$1
if [ "$COUNT" -ge 10 ]; then echo "At least 10"
elif [ "$COUNT" -ge 0 ]; then echo "Non-negative"
else echo "Negative"; fi
