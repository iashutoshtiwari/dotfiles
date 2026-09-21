#!/usr/bin/env bash
# Inventory only. Never import live configuration over repository sources.
set -euo pipefail
export LC_ALL=C
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
[[ $# == 0 ]] || { echo "Usage: $0" >&2; exit 2; }
[[ $EUID != 0 ]] || { echo 'Run as the desktop user, without sudo.' >&2; exit 1; }
mkdir -p -- "$repo/state"
staging=$(mktemp -d "$repo/state/.snapshot.XXXXXXXX")
trap 'rm -rf -- "$staging"' EXIT

# pacman returns 1 if the requested package selection is empty.
packages() {
    local result
    if result=$(pacman "$1"); then
        [[ -z $result ]] || printf '%s\n' "$result"
    else
        local status=$?
        [[ $status == 1 && -z $result ]] || return "$status"
    fi
}
packages -Qqen | sort > "$staging/packages-official.txt"
packages -Qqem | sort > "$staging/packages-foreign.txt"
systemctl list-unit-files --state=enabled --no-legend --no-pager |
    awk '{print $1}' | sort > "$staging/services-system.txt"
systemctl --user list-unit-files --state=enabled --no-legend --no-pager |
    awk '{print $1}' | sort > "$staging/services-user.txt"

# Collect every command successfully before replacing any snapshot.
for name in packages-official packages-foreign services-system services-user; do
    chmod 644 "$staging/$name.txt"
    mv -fT -- "$staging/$name.txt" "$repo/state/$name.txt"
done
echo 'Package/service snapshots updated. System configuration was not imported.'
