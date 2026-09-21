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
| A — Reproducible startup | IN PROGRESS | Existing autostart entry tracked and symlinked, backup retained; active generated service verified. Portable account paths and reinstall testing remain. |
| A — Runtime tooling state | DONE | Generated .qmlls.ini untracked and ignored; live symlink retained. |
| B — Wallpaper backend | IN PROGRESS | Single image symlink shared by Hyprpaper/Hyprlock; atomic serialized selection and failure rollback tested; tracked config stays fixed. Real lock/unlock and reboot verification remain. |
| B — Persistence | TODO | Selector and independent daemon-restart persistence verified; next login/reboot still needs testing. |
| B — Lock integration | IN PROGRESS | Exact image command verified against shared symlink; actual locked image and successful unlock still require interaction. |
| B — Wallpaper picker | TODO | Only after backend verification; optional manual rotation, no automatic rotation. |
| C — Kitty | IN PROGRESS | Removed unsupported border-radius key; installed parser loads without warnings, Mocha/11.5pt/0.94 opacity/10px padding/tab threshold verified; fontconfig resolves JetBrains Mono. Visual rendering/transparency/multiple tabs remain. |
| D — Brightness | TODO | Identify internal backlight, service/slider/percentage, keyboard controls; no unsupported external-display claims. |
| E — Night light | TODO | Verify installed/current Hyprsunset support; enable/temperature/manual schedule; no geolocation dependency. |
| F — Shared OSD | TODO | Single reusable framework: output/mute/mic/brightness, optional supported keyboard light and reliable Caps Lock; brief/subtle/no overlap. |
| G — Notifications | TODO | Quickshell daemon, transient/history/center/DND/actions/previews; clean grouping; replies only when supported. |
| H — Launcher | TODO | Quickshell Super+Space: fuzzy apps, files, calculator, actions, explicit command mode. Replace existing temporary Rofi binding in a separate change. |
| I — Tray | TODO | Deliberate StatusNotifierItem presentation and menus. |
| J — Weather | TODO | Open-Meteo or equivalent no-key provider; user-chosen location, Celsius/metric, small bar indicator and compact forecast. |
| K — Power menu | TODO | Lock, UWSM logout, suspend, deliberate reboot/shutdown; hibernate only after support is established. |
| L — Emoji / symbols | TODO | Separate lightweight utility. |
| M — Screenshots / OBS | TODO | Audit installed tools, grim/slurp clipboard/file workflow and bindings; OBS remains recording workflow. |
| N — Applications | TODO | Audit Dolphin, Firefox, Kate, VS Code, optional JetBrains IDEs, Okular, Gwenview, mpv/uosc, Ark, KCalc, btop, Filelight, KeePassXC, OBS, qBittorrent, Spotify. Prefer official packages. |
| O — Theming | TODO | Papirus Dark/Lavender folders, Bibata, GTK/Qt, Firefox, VS Code/JetBrains, maintainable Spotify, mpv/uosc, best-effort LibreOffice; maintained ports only. |
| O — Zsh / Starship | IN PROGRESS | Packages installed; account still Bash; inspect existing dotfiles, configure minimal prompt and test before changing login shell. |
| P — Hyprland | IN PROGRESS | Lua loads; resolve duplicate Super+L, audit rules/dialogs/fullscreen/workspaces/gestures/gaps/borders/startup/UWSM/env. |
| Q — Shell services | IN PROGRESS | Audio/media/network/DNS/Bluetooth/battery/profiles implemented; verify actions, reconnection, hotplug and error states. |
| Q — UX | TODO | Alignment, placement, hover/targets, keyboard focus, fonts/icons/spacing, animation/dismissal, multiple monitors, empty states; inspect portal warning. |
| R — Failed units | DONE | No failed system or user units at handoff; repeat after changes. |
| R — Final reliability | TODO | Relevant journals, Hyprland/QML warnings, greetd login, lock/unlock, configured suspend/resume, Intel renderer, PRIME, audio/Bluetooth/network/TLP/wallpaper, boot reliability, orphans and startup performance. |

Work subsystem by subsystem. Check installed versions and upstream documentation,
preserve a known-good rollback, validate before reload, test behavior, review diff,
update this checklist and commit only the coherent change. Do not automatically
push or remove backups. Interactive authentication, reboot and visual checks
remain unverified until actually exercised.
