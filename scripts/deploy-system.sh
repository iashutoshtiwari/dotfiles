#!/usr/bin/env bash
# Explicit deployment only; never restarts a login/session service.
set -euo pipefail
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode=${1:---dry-run}
[[ $# -le 1 && ( $mode == --dry-run || $mode == --apply ) ]] || {
    echo "Usage: $0 [--dry-run|--apply]" >&2; exit 2;
}
files=(
    etc/greetd/config.toml
    etc/greetd/hyprland-greeter.lua
    etc/systemd/zram-generator.conf
    etc/xdg/quickshell/ghost-greeter/shell.qml
    etc/xdg/quickshell/ghost-greeter/wallpaper.svg
    usr/local/libexec/ghost-greeter
    usr/local/libexec/ghost-session
)
modes=(644 644 644 644 644 755 755)
changed=()
for i in "${!files[@]}"; do
    rel=${files[i]}
    src="$repo/system/$rel"
    dst="/$rel"
    [[ -f $src && ! -L $src && -r $src ]] || {
        echo "Missing, unreadable or symlink source: $src" >&2; exit 1;
    }
    # Refuse redirected destination paths, including symlinked ancestors.
    parent=$dst
    while [[ $parent != / ]]; do
        [[ ! -L $parent ]] || { echo "Refusing symlink: $parent" >&2; exit 1; }
        parent=$(dirname -- "$parent")
    done
    [[ ! -e $dst || -f $dst ]] || { echo "Not a regular file: $dst" >&2; exit 1; }
    if [[ -f $dst ]] && cmp -s -- "$src" "$dst" &&
        [[ $(stat -c '%a:%u:%g' -- "$dst") == "${modes[i]}:0:0" ]]; then
        printf 'UNCHANGED %s\n' "$dst"
    else
        changed+=("$i")
        printf 'INSTALL root:root %s %s -> %s\n' "${modes[i]}" "$src" "$dst"
        if [[ -r $dst ]]; then
            diff -u -- "$dst" "$src" || [[ $? == 1 ]]
        fi
    fi
done
# Validate all shell entrypoints before any destination is modified.
sh -n "$repo/system/usr/local/libexec/ghost-greeter"
sh -n "$repo/system/usr/local/libexec/ghost-session"

obsolete=()
has_obsolete=0
for cand in /usr/local/libexec/*-greeter /usr/local/libexec/*-session /etc/xdg/quickshell/*-greeter; do
    [[ -e $cand ]] || continue
    rel=${cand#/}
    if [[ $rel != usr/local/libexec/ghost-greeter && $rel != usr/local/libexec/ghost-session && $rel != etc/xdg/quickshell/ghost-greeter ]]; then
        obsolete+=("$rel")
        has_obsolete=1
        printf 'OBSOLETE /%s (will remove on --apply)\n' "$rel"
    fi
done

[[ $mode == --apply && ( ${#changed[@]} -gt 0 || $has_obsolete -eq 1 ) ]] || exit 0
[[ $EUID == 0 ]] || { echo 'Apply requires root: sudo scripts/deploy-system.sh --apply' >&2; exit 1; }
umask 077
backup_root=/var/backups
if [[ ! -e $backup_root ]]; then
    install -d -o root -g root -m 755 -- "$backup_root"
fi
[[ -d $backup_root && ! -L $backup_root ]] || {
    echo "Unsafe backup directory: $backup_root" >&2; exit 1;
}
backup=$(mktemp -d "$backup_root/ghost-desktop.XXXXXXXX")
printf 'Backup and recovery manifest: %s\n' "$backup"
# Back up every affected destination before the first replacement.
for i in "${changed[@]}"; do
    rel=${files[i]}
    if [[ -e /$rel ]]; then
        mkdir -p -- "$backup/$(dirname -- "$rel")"
        cp -a -- "/$rel" "$backup/$rel"
        printf 'RESTORE /%s from %s/%s\n' "$rel" "$backup" "$rel" >> "$backup/manifest"
    else
        printf 'NEW /%s (remove this file to roll back)\n' "$rel" >> "$backup/manifest"
    fi
done
staged=''
trap '[[ -z $staged ]] || rm -f -- "$staged"' EXIT
trap 'echo "Deployment interrupted or failed; inspect $backup/manifest to restore affected files. No services restarted." >&2' ERR
for i in "${changed[@]}"; do
    rel=${files[i]}
    parent=$(dirname -- "/$rel")
    [[ -d $parent ]] || install -d -o root -g root -m 755 -- "$parent"
    staged=$(mktemp "$parent/.ghost-deploy.XXXXXXXX")
    install -o root -g root -m "${modes[i]}" -- "$repo/system/$rel" "$staged"
    mv -fT -- "$staged" "/$rel"
    staged=''
done

# Back up and remove obsolete legacy files
for obs in "${obsolete[@]}"; do
    if [[ -e /$obs ]]; then
        mkdir -p -- "$backup/$(dirname -- "$obs")"
        cp -a -- "/$obs" "$backup/$obs"
        rm -rf -- "/$obs"
        printf 'REMOVED /%s (backed up to %s/%s)\n' "$obs" "$backup" "$obs" >> "$backup/manifest"
        printf 'REMOVED obsolete /%s\n' "$obs"
    fi
done

printf 'Deployment complete. No services restarted. Retain %s for rollback.\n' "$backup"
