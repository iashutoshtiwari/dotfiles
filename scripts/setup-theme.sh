#!/bin/sh
set -eu

scheme_url='https://raw.githubusercontent.com/catppuccin/kde/main/generated/color-schemes/CatppuccinMochaLavender.colors'
scheme_hash='d100716a75e1d4429d00e899ea6c98bc1b118c252bec89d1236e86123fe04d0e'
scheme_dir="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes"
scheme_path="$scheme_dir/CatppuccinMochaLavender.colors"
tmp_path="$scheme_path.tmp.$$"

mkdir -p "$scheme_dir"
trap 'rm -f "$tmp_path"' EXIT HUP INT TERM

curl --fail --location --silent --show-error "$scheme_url" -o "$tmp_path"
actual_hash=$(sha256sum "$tmp_path" | awk '{print $1}')
if [ "$actual_hash" != "$scheme_hash" ]; then
    printf '%s\n' 'Catppuccin KDE color scheme checksum mismatch' >&2
    exit 1
fi

if [ ! -f "$scheme_path" ] || ! cmp -s "$tmp_path" "$scheme_path"; then
    mv "$tmp_path" "$scheme_path"
else
    rm -f "$tmp_path"
fi

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme catppuccin-mocha-lavender-standard+default
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic
    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface font-name 'Inter 11'
fi

printf 'Installed %s\n' "$scheme_path"
