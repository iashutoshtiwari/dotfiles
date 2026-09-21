#!/usr/bin/env bash

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p \
    "$repo/system/etc/greetd" \
    "$repo/system/etc/xdg/quickshell" \
    "$repo/system/usr/local/libexec" \
    "$repo/state"

# Root-owned system configuration

sudo cp /etc/greetd/config.toml \
    "$repo/system/etc/greetd/config.toml"

if [[ -f /etc/greetd/hyprland-greeter.lua ]]; then
    sudo cp /etc/greetd/hyprland-greeter.lua \
        "$repo/system/etc/greetd/hyprland-greeter.lua"
fi

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

# Machine state

pacman -Qqen | sort \
    > "$repo/state/packages-official.txt"

pacman -Qqem | sort \
    > "$repo/state/packages-foreign.txt"

systemctl list-unit-files \
    --state=enabled \
    --no-legend \
    | awk '{print $1}' \
    | sort \
    > "$repo/state/services-system.txt"

systemctl --user list-unit-files \
    --state=enabled \
    --no-legend \
    | awk '{print $1}' \
    | sort \
    > "$repo/state/services-user.txt"

echo "System/state snapshot complete."
