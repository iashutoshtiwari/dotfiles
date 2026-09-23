#!/bin/sh
set -eu

scheme_url='https://raw.githubusercontent.com/catppuccin/kde/main/generated/color-schemes/CatppuccinMochaLavender.colors'
scheme_hash='d100716a75e1d4429d00e899ea6c98bc1b118c252bec89d1236e86123fe04d0e'
scheme_dir="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes"
scheme_path="$scheme_dir/CatppuccinMochaLavender.colors"

gtk_url='https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-lavender-standard%2Bdefault.zip'
gtk_hash='bce962098f32c676a0170f909b737eed0905d53b6e774f04f152256b5b6dce77'
themes_dir="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
gtk_theme_dir="$themes_dir/catppuccin-mocha-lavender-standard+default"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ghost-theme.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

# 1. Install KDE color scheme
mkdir -p "$scheme_dir"
scheme_tmp="$tmp_dir/CatppuccinMochaLavender.colors"
curl --fail --location --silent --show-error "$scheme_url" -o "$scheme_tmp"
actual_scheme_hash=$(sha256sum "$scheme_tmp" | awk '{print $1}')
if [ "$actual_scheme_hash" != "$scheme_hash" ]; then
    printf '%s\n' 'Catppuccin KDE color scheme checksum mismatch' >&2
    exit 1
fi

if [ ! -f "$scheme_path" ] || ! cmp -s "$scheme_tmp" "$scheme_path"; then
    mv "$scheme_tmp" "$scheme_path"
fi
printf 'Installed KDE color scheme: %s\n' "$scheme_path"

# 2. Install Catppuccin GTK theme
mkdir -p "$themes_dir"
if [ ! -f "$gtk_theme_dir/gtk-4.0/gtk.css" ]; then
    command -v unzip >/dev/null 2>&1 || {
        printf '%s\n' 'unzip is required to install the GTK theme: sudo pacman -S unzip' >&2
        exit 1
    }
    gtk_tmp="$tmp_dir/gtk-theme.zip"
    curl --fail --location --silent --show-error "$gtk_url" -o "$gtk_tmp"
    actual_gtk_hash=$(sha256sum "$gtk_tmp" | awk '{print $1}')
    if [ "$actual_gtk_hash" != "$gtk_hash" ]; then
        printf '%s\n' 'Catppuccin GTK theme checksum mismatch' >&2
        exit 1
    fi
    unzip -q -o "$gtk_tmp" -d "$themes_dir"
    printf 'Installed GTK theme: %s\n' "$gtk_theme_dir"
else
    printf 'GTK theme already present: %s\n' "$gtk_theme_dir"
fi

# 3. Apply GNOME / GSettings desktop preferences
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme catppuccin-mocha-lavender-standard+default
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic
    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface font-name 'Inter 10'
    printf 'Applied GSettings interface themes and fonts.\n'
fi
