#!/usr/bin/env bash
# Safe, idempotent dotfiles linker for Predator Arch Desktop
set -euo pipefail
export LC_ALL=C

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode=${1:---dry-run}

[[ $# -le 1 && ( $mode == --dry-run || $mode == --apply ) ]] || {
    echo "Usage: $0 [--dry-run|--apply]" >&2
    exit 2
}

[[ $EUID != 0 ]] || {
    echo "Run as the desktop user, without sudo." >&2
    exit 1
}

# Directories that are linked as an entire directory
dir_links=(
    "home/.config/hypr:.config/hypr"
    "home/.config/quickshell/predator-shell:.config/quickshell/predator-shell"
    "home/.config/kitty:.config/kitty"
    "home/.config/rofi:.config/rofi"
    "home/.config/gtk-3.0:.config/gtk-3.0"
    "home/.config/gtk-4.0:.config/gtk-4.0"
    "home/.config/zsh:.config/zsh"
)

# Files that are linked individually inside directories
file_links=(
    "home/.config/kdeglobals:.config/kdeglobals"
    "home/.config/starship.toml:.config/starship.toml"
    "home/.config/darklyrc:.config/darklyrc"
    "home/.config/dolphinrc:.config/dolphinrc"
    "home/.config/environment.d/10-path.conf:.config/environment.d/10-path.conf"
    "home/.config/environment.d/20-theme.conf:.config/environment.d/20-theme.conf"
    "home/.config/fontconfig/fonts.conf:.config/fontconfig/fonts.conf"
    "home/.config/kvantum/kvantum.kvconfig:.config/kvantum/kvantum.kvconfig"
    "home/.config/qt6ct/qt6ct.conf:.config/qt6ct/qt6ct.conf"
    "home/.config/qt6ct/style-colors.conf:.config/qt6ct/style-colors.conf"
    "home/.config/autostart/predator-shell.desktop:.config/autostart/predator-shell.desktop"
    "home/.config/xdg-desktop-portal/hyprland-portals.conf:.config/xdg-desktop-portal/hyprland-portals.conf"
    "home/.config/zsh/.zshenv:.zshenv"
    "home/.local/bin/set-wallpaper:.local/bin/set-wallpaper"
    "home/.local/bin/screenshot:.local/bin/screenshot"
    "home/.local/bin/emoji-picker:.local/bin/emoji-picker"
)

# Base directories to ensure
base_dirs=(
    "$HOME/.config"
    "$HOME/.config/quickshell"
    "$HOME/.config/autostart"
    "$HOME/.config/environment.d"
    "$HOME/.config/fontconfig"
    "$HOME/.config/kvantum"
    "$HOME/.config/qt6ct"
    "$HOME/.config/xdg-desktop-portal"
    "$HOME/.local/bin"
    "$HOME/Pictures/Wallpapers"
    "$HOME/Pictures/Screenshots"
)

backup_dir=""
backup_manifest=""

init_backup() {
    if [[ -z $backup_dir ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d-%H%M%S)
        backup_dir="$HOME/.config/predator-dotfiles-backup-$timestamp"
        mkdir -p -- "$backup_dir"
        backup_manifest="$backup_dir/manifest.txt"
        printf 'Backup initiated at %s\n' "$timestamp" > "$backup_manifest"
        printf 'Backup directory: %s\n' "$backup_dir"
    fi
}

# 1. Ensure required base directories exist
if [[ $mode == --apply ]]; then
    for dir in "${base_dirs[@]}"; do
        mkdir -p -- "$dir"
    done
fi

all_links=("${dir_links[@]}" "${file_links[@]}")
errors=0

for item in "${all_links[@]}"; do
    rel_src="${item%%:*}"
    rel_dst="${item##*:}"

    src="$repo/$rel_src"
    dst="$HOME/$rel_dst"

    [[ -e $src ]] || {
        echo "Source does not exist in repository: $src" >&2
        errors=$((errors + 1))
        continue
    }

    # Check if target is already the exact desired symlink
    if [[ -L $dst ]]; then
        current_target=$(readlink -- "$dst")
        canonical_src=$(realpath -- "$src")
        canonical_dst=$(realpath -m -- "$dst")

        if [[ $current_target == "$src" || $(realpath -- "$dst" 2>/dev/null) == "$canonical_src" ]]; then
            printf 'UNCHANGED %s -> %s\n' "$dst" "$src"
            continue
        fi
    fi

    # Target exists but is not the desired symlink
    if [[ -e $dst || -L $dst ]]; then
        if [[ $mode == --dry-run ]]; then
            printf 'BACKUP & REPLACE %s -> %s (current target will be backed up)\n' "$dst" "$src"
        else
            init_backup
            mkdir -p -- "$backup_dir/$(dirname -- "$rel_dst")"
            mv -- "$dst" "$backup_dir/$rel_dst"
            printf 'BACKUP %s -> %s/%s\n' "$dst" "$backup_dir" "$rel_dst" >> "$backup_manifest"
            mkdir -p -- "$(dirname -- "$dst")"
            ln -s -- "$src" "$dst"
            printf 'LINK %s -> %s\n' "$dst" "$src"
        fi
    else
        # Target does not exist
        if [[ $mode == --dry-run ]]; then
            printf 'LINK %s -> %s\n' "$dst" "$src"
        else
            mkdir -p -- "$(dirname -- "$dst")"
            ln -s -- "$src" "$dst"
            printf 'LINK %s -> %s\n' "$dst" "$src"
        fi
    fi
done

# 2. Synchronize bundled wallpapers to ~/Pictures/Wallpapers/ if missing
if [[ -d "$repo/home/Pictures/Wallpapers" ]]; then
    for wp in "$repo/home/Pictures/Wallpapers"/*; do
        [[ -f $wp ]] || continue
        name=$(basename -- "$wp")
        target_wp="$HOME/Pictures/Wallpapers/$name"
        if [[ ! -e $target_wp ]]; then
            if [[ $mode == --dry-run ]]; then
                printf 'COPY WALLPAPER %s -> %s\n' "$wp" "$target_wp"
            else
                mkdir -p -- "$HOME/Pictures/Wallpapers"
                cp -- "$wp" "$target_wp"
                printf 'COPIED WALLPAPER %s -> %s\n' "$name" "$target_wp"
            fi
        else
            printf 'WALLPAPER EXISTS %s\n' "$target_wp"
        fi
    done
fi

# 3. Validation
if [[ $mode == --apply ]]; then
    echo "=== Validating symlinks ==="
    failed_links=0
    for item in "${all_links[@]}"; do
        rel_dst="${item##*:}"
        dst="$HOME/$rel_dst"
        if [[ ! -L $dst ]]; then
            echo "ERROR: Missing symlink: $dst" >&2
            failed_links=$((failed_links + 1))
        elif ! readlink -e -- "$dst" >/dev/null 2>&1; then
            echo "ERROR: Broken symlink: $dst -> $(readlink -- "$dst")" >&2
            failed_links=$((failed_links + 1))
        fi
    done

    if (( failed_links > 0 )); then
        echo "Validation FAILED: $failed_links broken or missing symlinks." >&2
        exit 1
    fi
    echo "All symlinks validated successfully."
    if [[ -n $backup_dir ]]; then
        printf 'Original files backed up in %s\n' "$backup_dir"
    fi
else
    echo "Dry-run complete. Run with --apply to create links."
fi
