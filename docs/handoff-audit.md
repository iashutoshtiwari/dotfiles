# Handoff audit — 2026-09-21

Baseline: `54bc65e` (previous `1f133a8`). At entry the user had an uncommitted
Super+Space → Rofi binding and an untracked xdg-desktop-portal configuration.
These were preserved and excluded from the audit commit. No services were
restarted and no root-owned configuration was changed during this audit.

## Installed versions

| Component | pacman version |
| --- | --- |
| Hyprland | 0.56.2-3 |
| Quickshell | 0.3.1-1 |
| UWSM | 0.27.0-1 |
| greetd | 0.10.3-2 |
| Hyprlock | 0.9.6-3 |
| Hypridle | 0.1.8-2 |
| Hyprpaper | 0.8.4-8 |
| PipeWire | 1:1.6.8-1 |
| WirePlumber | 0.5.17-1 |
| NetworkManager | 1.58.1-1 |
| TLP / tlp-rdw / tlp-pd | 1.10.2-1 |
| Kitty | 0.48.2-1 |
| Zsh / Starship | 5.9.2-1 / 1.26.0-1 |

Zsh and Starship are already installed, but the account shell remains `/bin/bash`.
Rofi 2.0.0-1 is also installed; do not add more dependencies around that temporary
launcher. Shell configuration adoption needs a separate audit.

## Verified observations

- All four required live links resolve to the intended repository paths without
  cycles. Existing pre-dotfiles backups remain intact.
- All five tracked greeter/system files match live contents. Live configs have
  root:root 0644 and libexec scripts root:root 0755.
- UWSM's Hyprland service and session targets are active. Hyprland reports no
  config errors. This does not imply all bindings behave correctly.
- Quickshell has one listed Predator shell instance, and its log says
  `Configuration Loaded`. The current log has a Qt portal registration warning;
  no QML load error appeared in the inspected log.
- greetd, NetworkManager, Bluetooth, tlp-pd, UPower, Hypridle, Hyprpaper, PipeWire
  and WirePlumber are active; TLP's oneshot completed successfully.
- System and user `systemctl --failed` lists are empty.
- `hyprctl hyprpaper listactive` reports the saved Catppuccin_Arch.jpg. The image
  exists; the state file and current config select the same image.
- Latest Hyprpaper start reports one output. Earlier journal entries prove the
  missing `source=` path caused restart-limit failures. Current config has no
  source directive and no hyprpaper.d directory was found in the inspected tree.
- Kitty's installed parser resolves font size 11.5 and opacity 0.94. Its theme
  include chain reaches Catppuccin Mocha.

## Partial, broken or missing

- Kitty prints `Ignoring unknown config key: window_border_radius`. Fix in the
  Kitty subsystem after checking its current docs. Visual font/tab/transparency
  checks remain outstanding.
- Super+L is bound both to focus right and lock. Resolve this collision before
  considering the lock shortcut verified. Super+Space currently invokes Rofi,
  contrary to the intended Quickshell launcher architecture.
- Wallpaper selector overwrites state and tracked config before IPC success,
  parses human-readable monitor output and maintains two copies of selection.
  Failure/rollback, special-character paths, actual selection and login/reboot
  persistence have not been tested. Hyprlock consumes the state path, but no
  unlock or wallpaper rendering test was performed.
- Shell startup depends on an untracked live XDG autostart desktop entry.
  Its command is `/usr/bin/qs -c predator-shell`. This is a reinstall gap.
- Native services and popups exist for audio, networking/DNS, Bluetooth, media,
  calendar and power profiles. Their interactive operations, hotplug, errors,
  dismissal and multiple monitors still need functional tests.
- Network details refresh on popup use; event synchronization and DNS process
  concurrency merit review. These are review targets, not proven runtime bugs.
- No native launcher, notifications, brightness service, OSD, tray, weather,
  night-light controls or system action menu exists in the inspected shell.
  PowerPopup is battery/profile UI, not a logout/shutdown menu.
- User journal includes missing RTKit messages and portal registration warnings.
  Investigate impact separately; avoid unrelated zero-warning cleanup.
- Intel and NVIDIA devices are detected, but actual renderer/offload operation
  was not established by the hardware inventory. No GPU settings were changed.

## Stale and reproducibility concerns

- Tracked `.qmlls.ini` points into `/run/user/1000/quickshell/vfs/...`: generated,
  session-specific tooling state. Remove it from version control in repository
  cleanup while retaining whatever the live QML tooling requires.
- Pre-dotfiles backups are rollback assets, not authorized deletion targets.
- `pipewire-media-session.service` appears as not-found/inactive in the unit
  listing, while WirePlumber is active. Do not install a second session manager
  to satisfy this stale unit reference.
- Snapshot script mixes importing live system files with generating inventories;
  its recursive copy/delete behavior should be narrowed to explicit managed files.
- Snapshots were not regenerated during this read-mostly audit. They are an
  inventory baseline, not evidence of current completeness.

## Documentation consulted

Current upstream [Hyprpaper](https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/) and
[Hyprlock](https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/) documentation was
consulted for the wallpaper review. Installed package versions, actual IPC,
configs and logs take precedence over assumptions about latest-git docs.
No component configuration or Quickshell API was added in this audit.

## Next sequence

1. Close startup/snapshot/runtime-tooling reproducibility gaps, preserving user work.
2. Make wallpaper selection failure-safe and verify persistence and lock integration.
3. Fix Kitty warning and test appearance; resolve the lock binding collision in
   its own Hyprland change.
4. Brightness, night light, reusable OSD, notifications, native launcher, tray,
   weather (location chosen by user), power menu, application/theming and final UX.

Deployment script validation: Bash syntax, live dry-run (all five unchanged),
invalid-argument rejection, missing-source rejection and symlink-source rejection.
Live apply/rollback are intentionally not exercised against a working greeter;
root deployment remains a separate operational test.
