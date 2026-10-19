# Shared input and search helpers. Run exercise scripts from lab10.
export LC_ALL=C

die() { echo "Error: $*" >&2; exit 2; }
require_file() { [ -f "$1" ] && [ -r "$1" ] || die "'$1' is not a readable regular file"; }
require_directory() { [ -d "$1" ] && [ -r "$1" ] && [ -x "$1" ] || die "cannot list '$1'"; }
indicator_matches() {
    local status
    grep -qwF -- "$1" "$2"
    status=$?
    [ "$status" -le 1 ] || die "cannot search '$2'"
    return "$status"
}
count_failed() {
    local count status
    count=$(grep -cF -- 'Failed password' "$1")
    status=$?
    [ "$status" -le 1 ] || die "cannot count failed logins in '$1'"
    printf '%s\n' "$count"
}
