#!/usr/bin/env bash

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p \
    "$repo/home/.config" \
    "$repo/home/.local/bin" \
    "$repo/system/etc/greetd" \
    "$repo/system/etc/xdg/quickshell" \
    "$repo/system/usr/local/libexec" \
    "$repo/state"

rsync -a --delete \
    "$HOME/.config/hypr/" \
    "$repo/home/.config/hypr/"

rsync -a --delete \
    "$HOME/.config/quickshell/predator-shell/" \
    "$repo/home/.config/quickshell/predator-shell/"

if [[ -d "$HOME/.config/kitty" ]]; then
    rsync -a --delete \
        "$HOME/.config/kitty/" \
        "$repo/home/.config/kitty/"
fi

[[ -f "$HOME/.config/starship.toml" ]] \
    && cp "$HOME/.config/starship.toml" \
       "$repo/home/.config/starship.toml"

[[ -f "$HOME/.zshrc" ]] \
    && cp "$HOME/.zshrc" "$repo/home/.zshrc"

[[ -f "$HOME/.local/bin/set-wallpaper" ]] \
    && cp "$HOME/.local/bin/set-wallpaper" \
       "$repo/home/.local/bin/set-wallpaper"

sudo cp /etc/greetd/config.toml \
    "$repo/system/etc/greetd/config.toml"

[[ -f /etc/greetd/hyprland-greeter.lua ]] \
    && sudo cp /etc/greetd/hyprland-greeter.lua \
       "$repo/system/etc/greetd/hyprland-greeter.lua"

if [[ -d /etc/xdg/quickshell/predator-greeter ]]; then
    sudo rsync -a --delete \
        /etc/xdg/quickshell/predator-greeter/ \
        "$repo/system/etc/xdg/quickshell/predator-greeter/"
fi

for file in predator-greeter predator-session; do
    if [[ -f "/usr/local/libexec/$file" ]]; then
        sudo cp "/usr/local/libexec/$file" \
            "$repo/system/usr/local/libexec/$file"
    fi
done

sudo chown -R "$USER:$USER" "$repo/system"

pacman -Qqen | sort > "$repo/state/packages-official.txt"
pacman -Qqem | sort > "$repo/state/packages-foreign.txt"

systemctl list-unit-files --state=enabled --no-legend \
    | awk '{print $1}' \
    | sort \
    > "$repo/state/services-system.txt"

systemctl --user list-unit-files --state=enabled --no-legend \
    | awk '{print $1}' \
    | sort \
    > "$repo/state/services-user.txt"

echo "Snapshot complete."
