# Predator Desktop Design

This repository keeps the desktop near-black, compact, and technical. Catppuccin
Mocha supplies the depth hierarchy; Lavender is reserved for active, selected,
focused, and directly interactive states. Red, yellow, and green retain their
semantic meanings rather than becoming general decoration.

## Tokens

Quickshell tokens live in `home/.config/quickshell/predator-shell/theme/Theme.qml`.
The spacing scale is 4/8/12/16/24px. Shell UI uses JetBrains Mono Nerd Font;
application UI uses Inter. Borders are subtle and geometry is square by default:
radius zero is intentional, with circular geometry reserved for status dots and
other indicators whose shape communicates a point.

## Motion

Motion is feedback, not decoration. Shell motion uses a compact 80/100/130/170/
230ms family for micro, hover, toggle, popup, and spatial feedback; exits are
90–110ms. Entrances use a strong ease-out, exits use ease-in, and spatial motion
settles without overshoot. `Theme.reducedMotion` removes translations and scale
while retaining short fades.

Hyprland owns application windows, workspaces, normal Wayland popups, and Rofi.
Windows materialize from 98% over 190ms and close from 99% over 130ms. Pointer
move/resize interpolation is disabled. Workspaces use a directional 10%
slide-fade over 230ms; the Quickshell marker uses the same perceived duration.
Special workspaces fade in place. Layer surfaces fade globally, with Rofi
explicitly fading and QML-driven shell layers excluded to prevent double motion.

Quickshell owns internal popup, notification, and OSD motion. Popup cards use a
4px/1% entrance, notifications travel at most 12px, and the OSD uses 4px/1%.
Repeated OSD updates animate only the value and do not replay the entrance.
There are no looping animations, animated shaders, gradients, or idle timers
whose only purpose is rendering motion.

## Depth and blur

Normal application windows remain opaque. Shell surfaces use Catppuccin Base,
Mantle, and Surface colors to establish depth; compositor blur is disabled to
keep the Intel HD 630 desktop responsive and battery-conscious.

## Interaction

Hover changes surface emphasis without scaling. Press feedback should be
immediate and small. Popups remain anchored to their bar button and the popup
coordinator permits one open surface at a time. The five workspace slots stay
fixed while one Lavender marker translates between them.

## Maintenance

When adding a component, use the shared tokens before introducing a new value.
Keep APIs aligned with the installed Quickshell and Hyprland versions, validate
the affected component alone, and document intentional exceptions nearby.

## Action Center

The Action Center is a full-height right-side drawer (`predator-shell/actioncenter/`).
It replaces the old `NotificationCenter` popup and is architected to grow into a
general system control surface.

**Geometry:** 392 px wide (`Theme.actionCenterWidth`), starts immediately below the
floating bar, extends to the bottom of the monitor. Does not push or resize tiled
windows (`exclusiveZone: 0`, Overlay layer).

**Motion:** QML-owned horizontal slide — opens right→left in `motionSpatial` (~230 ms,
OutCubic), closes left→right in `motionNormal` (~170 ms, InCubic). Hyprland has
`no_anim` for the `predator-action-center` namespace to prevent double animation.
Backdrop fades from 0 → 0.28 opacity concurrently. Both are interruptible.

**Multi-monitor:** One `ActionCenter` instance per screen, created inside Bar.qml's
`Variants { model: Quickshell.screens }` scope. Each ActionCenter binds to its
screen; only one is open globally at a time via the Bar's popup coordinator.

**Closing triggers:** button toggle, backdrop click, Escape key, Super+N, workspace
switch, any bar popup opening, Rofi/emoji-picker launch (via `popups closeAll` IPC).

**Unread semantics:** Unread count increments only when the drawer is closed.
Opening the drawer calls `markAllRead()`. New notifications arriving while the drawer
is open appear inline without incrementing the badge.

**DND:** When on, toasts are suppressed but notifications still accumulate in history.
Notifications received while the drawer is open are also not toasted (already visible).

**Future modules:** To add Bluetooth, Displays, Printers, etc., create a component
in `actioncenter/modules/` and insert it above `NotificationList` in `ActionCenter.qml`.
`NotificationList` keeps `Layout.fillHeight: true` and fills remaining space.

**IPC:** `qs ipc -c predator-shell call actionCenter toggle|open|close`
**Keybind:** Super+N
