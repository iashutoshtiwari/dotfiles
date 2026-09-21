# Predator Arch Desktop

Source of truth for the Acer Predator Helios 300 desktop. Read [AGENTS.md](AGENTS.md)
before changes and [CHECKLIST.md](CHECKLIST.md) for scope and verification status.
The initial [handoff audit](docs/handoff-audit.md) records observed facts and gaps.

## Architecture

Login follows greetd → temporary Hyprland compositor → Quickshell greeter →
`predator-session` → UWSM → user Hyprland. Keep UWSM responsible for the session;
logout uses `uwsm stop`. The greeter compositor's direct exit is intentional.
Intel HD 630 is the intended desktop renderer; NVIDIA Pascal is for PRIME offload.
Do not change GPU ordering, initramfs, or boot configuration for desktop polish.

The user shell is `home/.config/quickshell/predator-shell/`: `shell.qml` composes
`bar/`, with separate `services/`, `components/`, `popups/`, and `theme/`.
Future launcher, notifications and OSD code should have their own directories.
Hyprlock handles authentication; Hypridle requests lock at 600 seconds and DPMS
off at 660 seconds. Hyprpaper displays wallpapers. TLP + tlp-pd provide power
profiles; do not enable power-profiles-daemon alongside them.

Catppuccin Mocha, Lavender, square geometry, JetBrains Mono Nerd Font shell UI,
Inter application UI, Papirus icons, restrained animation and no compositor blur.

Application theming is deliberately split by toolkit. Qt6 uses qt6ct with the
installed Catppuccin Kvantum style, Papirus-Dark icons and Inter; KDE
semantic colors come from the user-installed Catppuccin Mocha Lavender color
scheme in `~/.local/share/color-schemes`. GTK3/GTK4 use the installed Catppuccin
theme through their settings files, without a global `GTK_THEME` override. The
session-wide Qt and cursor variables live in `home/.config/environment.d/`; run
`scripts/setup-theme.sh` after installing or restoring the dotfiles. The setup
script also sets the supported GSettings dark preference used by GTK4/libadwaita.
There are currently no relevant Qt5 applications; `qt5ct` remains installed only
as a package removal candidate until the next package audit.

## Layout and live configuration

- `home/` mirrors home files. The Hyprland directory, Predator shell directory,
  Kitty directory, shell autostart entry and `set-wallpaper` script are currently symlinked here.
- `system/` holds copies of five explicitly managed root-owned greeter files.
  Editing these copies does not deploy them.
- `state/` holds generated inventories, not an installation manifest.
- `scripts/` holds management commands.

`set-wallpaper ~/Pictures/Wallpapers/image.jpg` atomically updates the single
selection symlink `~/.local/state/predator-shell/wallpaper`, then applies it through
Hyprpaper IPC (starting the user service if needed). A failed command restores the
previous selection. Hyprpaper resolves that link on startup; Hyprlock reads its
image target with `readlink -e`. `set-wallpaper --current` exposes the selection
for future Quickshell integration. The tracked config is never rewritten.
Images and selection state stay outside Git. Commas and line breaks in image
paths are rejected because the IPC format cannot represent them unambiguously.

The original text state is retained as `wallpaper.pre-symlink`. To roll back this
migration, first restore the previous selector/Hyprpaper/Hyprlock files together
from Git, then replace the symlink with that saved text file and restart only
Hyprpaper. Keep the backup. Reboot persistence and a real lock/unlock still need
interactive verification; daemon restart and the lock image command were tested.

## Reinstall outline

This is a recovery guide, not yet an unattended bootstrap script.

1. Prepare Arch, the user account, networking and SSH recovery independently.
   Review `state/packages-official.txt` and `state/packages-foreign.txt`; install
   needed official packages with pacman. Do not blindly install every snapshot
   entry or substitute a current NVIDIA branch for the required Pascal branch.
2. Clone into `~/dotfiles`. Recheck installed versions against upstream docs.
   The current greeter username is machine-specific;
   review them before deploying on a different account.
3. Compare existing configuration with each repository source. Move any existing
   destination to a unique rollback backup, then create the links below.
   Never run these over existing directories or with `ln -sf`:

   ```sh
   ln -s "$HOME/dotfiles/home/.config/hypr" "$HOME/.config/hypr"
   ln -s "$HOME/dotfiles/home/.config/quickshell/predator-shell" "$HOME/.config/quickshell/predator-shell"
   ln -s "$HOME/dotfiles/home/.config/kitty" "$HOME/.config/kitty"
   ln -s "$HOME/dotfiles/home/.local/bin/set-wallpaper" "$HOME/.local/bin/set-wallpaper"
   ln -s "$HOME/dotfiles/home/.config/autostart/predator-shell.desktop" "$HOME/.config/autostart/predator-shell.desktop"
   ```

   Create missing parent directories first and verify each result with `readlink -f`.
   Retain `*.pre-dotfiles` backups until explicit approval to remove them.

4. Restore a wallpaper into `~/Pictures/Wallpapers/` and initialize its state with
   `set-wallpaper` in a running session. Check the lock screen image separately.
5. Reconcile user service enablement against `state/services-user.txt`.
   The tracked XDG autostart entry starts the shell through the existing UWSM
   session autostart target; do not add a second shell startup command.
6. Review `scripts/deploy-system.sh --dry-run`. After version-specific validation,
   use `sudo scripts/deploy-system.sh --apply`. The script validates its explicit
   sources and shell entrypoint syntax, refuses destination symlinks, preserves
   backups, and installs root:root 0644 configs / 0755 executables. It does not
   validate QML/Lua behavior, enable units, or restart greetd.
7. Validate a login with a TTY/SSH recovery session available before relying on
   greetd at boot. Verify locking/unlocking, audio, network and wallpaper persistence.

## Recovery and changes

For user configs, save uncommitted work first. Use `git show COMMIT:path` to inspect
a known-good file, then restore only the affected file from that revision. Avoid
whole-tree resets. Symlinked files are live; Hyprland/Quickshell may reload them.
Use nano from a TTY or SSH if the graphical session is unusable.

System deployment saves originals under `/var/backups/predator-desktop.*` with a
manifest. From TTY/SSH, restore each listed original using `sudo cp -a` from its
backup path to the corresponding absolute destination. For NEW entries, remove
only that exact newly deployed file. Deployment is atomic per file, not across
all five files: a failure requires consulting the whole manifest. Restart greetd
only deliberately from recovery; doing so terminates graphical login/session work.

`scripts/snapshot.sh` generates package/service inventories as the desktop user,
without sudo. It stages all command results before replacing snapshots and never
imports live configs over repository files. To adopt a deliberate live system
change, compare and copy only that named managed file, review the diff and commit.
Never hand-edit state snapshots or copy NetworkManager secrets into Git.

Work one subsystem per commit: inspect, check installed-version documentation,
implement, validate, inspect logs and diff, update the checklist, then commit.
Do not push automatically. Login, lock and reboot tests require deliberate user
interaction; a running process alone is not proof of end-to-end success.
