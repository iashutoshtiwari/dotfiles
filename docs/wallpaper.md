# Wallpaper backend

Validated against installed Hyprpaper 0.8.4 and Hyprlock 0.9.6. The current
[Hyprpaper documentation](https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/),
[versioned path resolver](https://github.com/hyprwm/hyprpaper/blob/v0.8.4/src/config/ConfigManager.cpp),
[IPC implementation](https://github.com/hyprwm/hyprpaper/blob/v0.8.4/src/ipc/IPC.cpp),
and [Hyprlock image loader](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/renderer/widgets/Background.cpp)
were checked before this change.

`~/.local/state/ghost-shell/wallpaper` is now an image symlink, not a text file.
Hyprpaper's fixed config resolves it at startup, while Hyprlock's image command
returns its target. The selector writes neither configuration nor a second copy
of the selected path. A future picker can call `set-wallpaper` and read
`set-wallpaper --current`. No palette extraction or automatic rotation is added.

The selector validates a readable image under the canonical wallpaper directory,
serializes writers with flock, stages a link on the same filesystem and atomically
replaces the selection. On a command failure it restores the old link and tries
to restore the old displayed image. Startup waits up to three seconds for IPC.
An uncatchable termination after the link replacement can leave the new selection
saved before display changes; restarting Hyprpaper reconciles it. IPC success
means the daemon accepted the change, not proof every image decoder can decode
arbitrary corrupt files. MIME checking rejects obvious non-images.

Tests performed:

- Current image applied through real IPC; saved link resolves correctly.
- A copy of the image in a path with spaces, `#` and `$` applies successfully.
- Independent Hyprpaper restart loads the saved image without invoking selector.
- Non-image and comma-containing paths are rejected without changing selection.
- Injected IPC failure restores the previous selection.
- Tracked config remains byte-identical across selection changes.
- Original wallpaper restored after tests; recent daemon journal has no warnings.
- Exact Hyprlock reload command returns a valid selected image path.

Still pending: actual lock rendering/unlock, next login/reboot, multiple outputs
and physical hotplug. No picker should be built until those backend checks pass.
