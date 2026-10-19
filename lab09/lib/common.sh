# Shared guards, counting and extension checks for the Lab 9 for-loop scripts.
# Source from an exercise script; working directory is lab09.
export LC_ALL=C

die() { echo "Error: $*" >&2; exit 2; }
require_file() {
    [ -f "$1" ] && [ -r "$1" ] || die "'$1' is not a readable regular file"
}
require_directory() {
    [ -d "$1" ] && [ -r "$1" ] && [ -x "$1" ] || die "cannot list '$1'"
}
load_logs() {
    require_directory case/logs
    LOGFILES=()
    for LOGFILE in case/logs/*.log; do
        [ -f "$LOGFILE" ] || continue
        require_file "$LOGFILE"
        LOGFILES+=("$LOGFILE")
    done
    [ "${#LOGFILES[@]}" -gt 0 ] || die "no regular .log files in case/logs"
}
load_indicators() {
    require_file intel/iocs.txt
    # Preserve complete lines, including spaces; the for loop still visits each IOC.
    mapfile -t RAW_INDICATORS < intel/iocs.txt || die "cannot read indicators"
    INDICATORS=()
    for INDICATOR in "${RAW_INDICATORS[@]}"; do
        INDICATOR=${INDICATOR%$'\r'}
        [ -n "$INDICATOR" ] && INDICATORS+=("$INDICATOR")
    done
    [ "${#INDICATORS[@]}" -gt 0 ] || die "indicator list is empty"
}
count_lines() {
    local count status
    count=$(grep -c "$@")
    status=$?
    # grep status 1 means zero matches; status >1 is a real search error.
    [ "$status" -le 1 ] || return "$status"
    printf '%s\n' "$count"
}
classify_type() {
    local filename=$1 detected=$2
    EXPECT=""
    if [[ "$filename" == *.png ]]; then EXPECT=PNG
    elif [[ "$filename" == *.zip ]]; then EXPECT=Zip
    elif [[ "$filename" == *.txt || "$filename" == *.md || "$filename" == *.log ]]; then EXPECT=text
    elif [[ "$filename" == *.sh ]]; then EXPECT='shell script'
    elif [[ "$filename" == *.py ]]; then EXPECT=Python
    elif [[ "$filename" == *.bin ]]; then
        if [ -s "$filename" ]; then EXPECT=data; else EXPECT=empty; fi
    elif [[ "$filename" == *.dat ]]; then EXPECT=data
    fi
    if [ -z "$EXPECT" ]; then MARK='??'
    elif [[ "$detected" == *"$EXPECT"* ]]; then MARK=OK
    else MARK='!!'; fi
}
