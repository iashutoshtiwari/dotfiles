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

Motion is feedback, not decoration. Quickshell uses fast 120ms and normal 180ms
transitions, with a shorter 90ms exit where appropriate. Hyprland uses one
restrained Bézier curve: windows pop in from 94%, close faster, workspaces use a
short slide-fade, and special workspaces use an even shorter slide-fade. There
are no continuous or looping effects.

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
