# Desktop engineering checklist

Updated 2026-09-21. DONE means the stated check was performed; IN PROGRESS means
an implementation exists with remaining work or verification. TODO does not
imply a broken live system. See [audit evidence](docs/handoff-audit.md).

| Area | Status | Work / remaining acceptance criteria |
| --- | --- | --- |
| A — Handoff audit | DONE | Inspect Git, tree, versions, symlinks, configs, services and wallpaper state; record evidence and limits. |
| A — User symlinks | DONE | Hyprland, Predator shell, Kitty and set-wallpaper resolve into repo; retain rollback copies. |
| A — System deployment | IN PROGRESS | Explicit five-file script added; dry-run/preflight tested; root apply/rollback still needs operational test. |
| A — Snapshot maintenance | DONE | Inventory-only script stages all results before replacement, rejects root, never imports system files; snapshots regenerated. |
| A — Bootstrap and recovery docs | DONE | Architecture, link adoption, deploy boundaries and recovery documented in README. |
| A — Reproducible startup | IN PROGRESS | Existing autostart entry tracked and symlinked, backup retained; updated with `--no-duplicate` to prevent redundant instances; active generated service verified. Portable account paths and reinstall testing remain. |
| A — Runtime tooling state | DONE | Generated .qmlls.ini untracked and ignored; live symlink retained. |
| B — Wallpaper backend | IN PROGRESS | Single image symlink shared by Hyprpaper/Hyprlock; atomic serialized selection and failure rollback tested; tracked config stays fixed. Real lock/unlock and reboot verification remain. |
| B — Persistence | TODO | Selector and independent daemon-restart persistence verified; next login/reboot still needs testing. |
| B — Lock integration | IN PROGRESS | Exact image command verified against shared symlink; actual locked image and successful unlock still require interaction. |
| B — Wallpaper picker | DONE | Visual Wallpaper gallery popup (popups/WallpaperPicker.qml, 400x480) with 16:9 thumbnail previews, active badge, and direct Hyprpaper atomic switching via set-wallpaper; integrated into DisplayPopup and bound to Super+W; verified via tests/shell/phase4-smoke.py. |
| C — Kitty | IN PROGRESS | Removed unsupported border-radius key; installed parser loads without warnings, Mocha/11.5pt/0.94 opacity/10px padding/tab threshold verified; fontconfig resolves JetBrains Mono. Visual rendering/transparency/multiple tabs remain. |
| D — Brightness | DONE | Discovered intel_backlight; BrightnessService singleton with clamp [5, 100], slider, presets, and scrollwheel on bar; hyprland.lua XF86MonBrightness keys integrated via IPC with fallback; tested via tests/shell/brightness-smoke.py. |
| E — Night light | DONE | Hyprsunset v0.4.0 verified and integrated; NightLightService singleton with IPC socket control, color temperature slider, presets (Cool, Warm, Cozy, Candle), and manual schedule (20:00–07:00); DisplayPopup integration complete. |
| F — Shared OSD | DONE | Single reusable OSD overlay window (osd/OsdWindow.qml) for speaker volume, mute, microphone level, mic mute, brightness, Caps Lock, Num Lock, Scroll Lock, and Airplane Mode (hardware keyboard backlight confirmed unexposed by laptop EC firmware and excluded from software scope); lower-center placement with restrained fade animation, integer multiple-of-4 sizing under 1.25x scaling, and reset-on-change timer; verified via tests/shell/osd-extensions-smoke.py and live reload. |
| G — Notifications | DONE | Native Quickshell NotificationServer singleton (services/NotificationService.qml) registered on DBus org.freedesktop.Notifications; transient floating toasts overlay (notifications/NotificationToasts.qml) with urgency styles, icons, actions, auto-dismiss; full Notification Center popup (popups/NotificationCenter.qml) with DND toggle, clear-all, and scrollable history; top-bar unread counter badge (bar/NotificationButton.qml); verified via tests/shell/phase3-smoke.py and live notify-send. |
| H — Launcher | DONE | Rofi confirmed as the application launcher on Super+Space (bound in `hyprland.lua`). Quickshell launcher is out of scope per user specification. |
| I — Tray | DONE | Dedicated StatusNotifierItem integration (bar/TrayWidget.qml) using Quickshell.Services.SystemTray; clean 26x26 item slots with 18x18 icons, left/middle click activation, native popup context menu (item.display), and wheel scroll pass-through; verified via live reload. |
| J — Weather | DONE | Native Open-Meteo REST service (services/WeatherService.qml) for Lucknow, UP (26.8467° N, 80.9462° E); top-bar temperature/condition button (bar/WeatherButton.qml); 320x336 forecast popup (popups/WeatherPopup.qml) with feels-like, humidity, wind, and 3-day forecast with manual refresh; verified via tests/shell/phase4-smoke.py. |
| K — Power menu | DONE | Session power popup (popups/PowerMenuPopup.qml) with lock (loginctl lock-session), suspend (systemctl suspend), logout (uwsm stop), and two-stage confirmed restart/shutdown (systemctl reboot/poweroff); top-bar power button (bar/PowerButton.qml) and Super+Backspace keybinding in hyprland.lua; multiple-of-4 sizing (320x336); verified via tests/shell/phase3-smoke.py and live IPC toggling. |
| L — Emoji / symbols | DONE | Lightweight emoji utility (home/.local/bin/emoji-picker) with curated 256-emoji dictionary, fuzzy search via rofi -dmenu, wl-copy integration, and Super+period binding in hyprland.lua; auto-upgrades to rofi-emoji plugin if installed; verified via tests/shell/phase5-smoke.py. |
| M — Screenshots / OBS | DONE | Dedicated screenshot utility (home/.local/bin/screenshot) with grim + slurp styled with Catppuccin Mocha colors, saving to ~/Pictures/Screenshots, copying to clipboard via wl-copy, and emitting detached rich notifications with View and Open Folder actions; Hyprland bindings for Print, Super+Shift+S (area), Shift+Print (screen), and Ctrl+Print (window); verified via tests/shell/phase4-smoke.py; OBS retained for recording. |
| N — Applications | TODO | Audit Dolphin, Firefox, Kate, VS Code, optional JetBrains IDEs, Okular, Gwenview, mpv/uosc, Ark, KCalc, btop, Filelight, KeePassXC, OBS, qBittorrent, Spotify. Prefer official packages. |
| O — Theming | TODO | Papirus Dark/Lavender folders, Bibata, GTK/Qt, Firefox, VS Code/JetBrains, maintainable Spotify, mpv/uosc, best-effort LibreOffice; maintained ports only. |
| O — Zsh / Starship | IN PROGRESS | Packages installed; account still Bash; inspect existing dotfiles, configure minimal prompt and test before changing login shell. |
| P — Hyprland | DONE | Lua config loads cleanly (0 errors); Super+Space bound to Rofi with popups closeAll; Super+Escape bound to lock-session with popups closeAll; window rules audited and active (suppress-maximize, file dialogs float, portal float, PiP float/pin, utilities float, XWayland drag fix); gestures, gaps, borders, workspaces, and input verified via tests/shell/phase5-smoke.py. |
| Q — Shell services | DONE | Audio/media/network/DNS/Bluetooth/battery/profiles audited and stabilized; MprisService togglePlaying() and AudioService null-safety applied; NetworkService hardened with atomic queries and concurrency locks; verified via tests/shell/network-smoke.py and live reload. |
| Q — UX | DONE | Unified Popup Coordinator in Bar.qml ensuring single active popup, mutual exclusion, and global IPC closeAll method; full multiple-of-4 scaling audit across all 10 popups (DisplayPopup, AudioPopup, ClockPopup dynamic heights rounded with Math.ceil(h/4)*4) preventing fractional clipping or blur under 1.25x scaling; verified via tests/shell/phase5-smoke.py. |
| R — Failed units | DONE | No failed system or user units at handoff; repeat after changes. |
| R — Final reliability | TODO | Relevant journals, Hyprland/QML warnings, greetd login, lock/unlock, configured suspend/resume, Intel renderer, PRIME, audio/Bluetooth/network/TLP/wallpaper, boot reliability, orphans and startup performance. |

Work subsystem by subsystem. Check installed versions and upstream documentation,
preserve a known-good rollback, validate before reload, test behavior, review diff,
update this checklist and commit only the coherent change. Do not automatically
push or remove backups. Interactive authentication, reboot and visual checks
remain unverified until actually exercised.
