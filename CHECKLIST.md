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
| B — Wallpaper picker | TODO | Only after backend verification; optional manual rotation, no automatic rotation. |
| C — Kitty | IN PROGRESS | Removed unsupported border-radius key; installed parser loads without warnings, Mocha/11.5pt/0.94 opacity/10px padding/tab threshold verified; fontconfig resolves JetBrains Mono. Visual rendering/transparency/multiple tabs remain. |
| D — Brightness | DONE | Discovered intel_backlight; BrightnessService singleton with clamp [5, 100], slider, presets, and scrollwheel on bar; hyprland.lua XF86MonBrightness keys integrated via IPC with fallback; tested via tests/shell/brightness-smoke.py. |
| E — Night light | DONE | Hyprsunset v0.4.0 verified and integrated; NightLightService singleton with IPC socket control, color temperature slider, presets (Cool, Warm, Cozy, Candle), and manual schedule (20:00–07:00); DisplayPopup integration complete. |
| F — Shared OSD | DONE | Single reusable OSD overlay window (osd/OsdWindow.qml) for speaker volume, mute, microphone level, mic mute, brightness, Caps Lock, Num Lock, Scroll Lock, and Airplane Mode (hardware keyboard backlight confirmed unexposed by laptop EC firmware and excluded from software scope); lower-center placement with restrained fade animation, integer multiple-of-4 sizing under 1.25x scaling, and reset-on-change timer; verified via tests/shell/osd-extensions-smoke.py and live reload. |
| G — Notifications | TODO | Quickshell daemon, transient/history/center/DND/actions/previews; clean grouping; replies only when supported. |
| H — Launcher | DONE | Rofi confirmed as the application launcher on Super+Space (bound in `hyprland.lua`). Quickshell launcher is out of scope per user specification. |
| I — Tray | TODO | Deliberate StatusNotifierItem presentation and menus. |
| J — Weather | TODO | Open-Meteo or equivalent no-key provider; user-chosen location, Celsius/metric, small bar indicator and compact forecast. |
| K — Power menu | TODO | Lock, UWSM logout, suspend, deliberate reboot/shutdown; hibernate only after support is established. |
| L — Emoji / symbols | TODO | Separate lightweight utility. |
| M — Screenshots / OBS | TODO | Audit installed tools, grim/slurp clipboard/file workflow and bindings; OBS remains recording workflow. |
| N — Applications | TODO | Audit Dolphin, Firefox, Kate, VS Code, optional JetBrains IDEs, Okular, Gwenview, mpv/uosc, Ark, KCalc, btop, Filelight, KeePassXC, OBS, qBittorrent, Spotify. Prefer official packages. |
| O — Theming | TODO | Papirus Dark/Lavender folders, Bibata, GTK/Qt, Firefox, VS Code/JetBrains, maintainable Spotify, mpv/uosc, best-effort LibreOffice; maintained ports only. |
| O — Zsh / Starship | IN PROGRESS | Packages installed; account still Bash; inspect existing dotfiles, configure minimal prompt and test before changing login shell. |
| P — Hyprland | IN PROGRESS | Lua loads; Rofi Super+Space bound; duplicate Super+L resolved by binding lock to Super+Escape; audit rules/dialogs/fullscreen/workspaces/gestures/gaps/borders/startup/UWSM/env. |
| Q — Shell services | DONE | Audio/media/network/DNS/Bluetooth/battery/profiles audited and stabilized; MprisService togglePlaying() and AudioService null-safety applied; NetworkService hardened with atomic queries and concurrency locks; verified via tests/shell/network-smoke.py and live reload. |
| Q — UX | IN PROGRESS | Resolved missing right-side border on Network, Battery, Bluetooth, and Clock popups by sizing implicit dimensions to multiples of 4 (eliminating fractional buffer truncation under 1.25x display scaling); tested with grim/ppm verification and live reload. |
| R — Failed units | DONE | No failed system or user units at handoff; repeat after changes. |
| R — Final reliability | TODO | Relevant journals, Hyprland/QML warnings, greetd login, lock/unlock, configured suspend/resume, Intel renderer, PRIME, audio/Bluetooth/network/TLP/wallpaper, boot reliability, orphans and startup performance. |

Work subsystem by subsystem. Check installed versions and upstream documentation,
preserve a known-good rollback, validate before reload, test behavior, review diff,
update this checklist and commit only the coherent change. Do not automatically
push or remove backups. Interactive authentication, reboot and visual checks
remain unverified until actually exercised.
