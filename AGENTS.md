# Ghost Arch Desktop

This repository is the source of truth for my custom Arch Linux + Hyprland desktop.

## Environment

- Arch Linux
- Hyprland, Lua configuration
- UWSM session management
- Quickshell custom desktop shell
- greetd + Quickshell greeter
- Hyprlock + Hypridle
- Hyprpaper
- PipeWire + WirePlumber
- NetworkManager
- TLP + tlp-rdw + tlp-pd
- Intel HD 630 drives the desktop
- NVIDIA GTX 1050 Ti is PRIME/offload only

## Design

- Catppuccin Mocha
- Lavender accent
- JetBrains Mono Nerd Font for custom shell UI
- Inter for normal application UI
- Papirus icons
- Boxy UI
- No rounded corners except semantically circular elements
- Minimal blur
- Restrained animations
- Floating top bar

## Repository layout

- `home/` mirrors `$HOME`
- `system/etc/` mirrors `/etc`
- `system/usr/` mirrors `/usr`
- `state/` contains generated package/service snapshots
- `scripts/` contains maintenance/deployment scripts

## Rules

1. Use current upstream documentation before changing Hyprland, Quickshell,
   greetd, Hyprlock, Hypridle, Hyprpaper, UWSM, TLP, or systemd configuration.
2. Do not use deprecated Hyprland syntax.
3. Hyprland configuration is Lua.
4. Do not replace UWSM with direct compositor launching.
5. Do not add Waybar, Rofi, SwayNC, SDDM, KDE Plasma, or GNOME.
6. Do not install AUR packages unless necessary.
7. Do not modify NVIDIA/initramfs configuration unless explicitly required.
8. Do not use `pacman -Rdd`.
9. Keep changes small and auditable.
10. Do not edit generated state files manually.
11. Never commit credentials, SSH keys, NetworkManager secrets, API keys, or
    private tokens.
12. Preserve the existing Catppuccin Mocha + Lavender design language.

## Quickshell

The main shell lives at:

`home/.config/quickshell/ghost-shell/`

Keep services, bar components, popups, launcher, notifications, and OSDs
separated by responsibility.

Before adding Quickshell API usage, verify it against the currently installed
Quickshell version and upstream documentation.

## System files

Files under `system/` are copies of root-owned configuration.

Do not assume editing them changes the live system. They must be deployed
explicitly.
