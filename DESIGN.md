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
