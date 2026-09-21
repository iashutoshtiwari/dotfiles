pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Catppuccin Mocha
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo:  "#f2cdcd"
    readonly property color pink:      "#f5c2e7"
    readonly property color mauve:     "#cba6f7"
    readonly property color red:       "#f38ba8"
    readonly property color maroon:    "#eba0ac"
    readonly property color peach:     "#fab387"
    readonly property color yellow:    "#f9e2af"
    readonly property color green:     "#a6e3a1"
    readonly property color teal:      "#94e2d5"
    readonly property color sky:       "#89dceb"
    readonly property color sapphire:  "#74c7ec"
    readonly property color blue:      "#89b4fa"
    readonly property color lavender:  "#b4befe"

    readonly property color text:      "#cdd6f4"
    readonly property color subtext1:  "#bac2de"
    readonly property color subtext0:  "#a6adc8"

    readonly property color overlay2:  "#9399b2"
    readonly property color overlay1:  "#7f849c"
    readonly property color overlay0:  "#6c7086"

    readonly property color surface2:  "#585b70"
    readonly property color surface1:  "#45475a"
    readonly property color surface0:  "#313244"

    readonly property color base:      "#1e1e2e"
    readonly property color mantle:    "#181825"
    readonly property color crust:     "#11111b"

    // Our design system
    readonly property color accent: lavender

    readonly property string shellFont: "JetBrainsMono Nerd Font"
    // The compact monospace face gives the shell its technical character.
    // Keep the alias so shared controls still have one typography entry point.
    readonly property string appFont: shellFont

    // Typography is deliberately split: Inter carries information while the
    // Nerd Font is reserved for symbolic glyphs and compact technical values.
    readonly property int textSmall: 10
    readonly property int textBody: 12
    readonly property int textBodyStrong: 12
    readonly property int textHeading: 15
    readonly property int textValue: 13

    readonly property int barHeight: 38
    readonly property int barMargin: 8

    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 24

    readonly property int rowCompact: 32
    readonly property int rowNormal: 40
    readonly property int rowLarge: 56
    readonly property int rowSlider: 50

    readonly property int popupCompact: 320
    readonly property int popupStandard: 360
    readonly property int popupWide: 392
    readonly property int popupPadding: 16

    // Shared shell geometry. Keep surfaces square; circular geometry belongs to
    // indicators whose shape communicates a point or status.
    readonly property int borderWidth: 1
    readonly property int activeBorderWidth: 2
    readonly property int workspaceSlot: 31
    readonly property int workspaceDot: 8
    readonly property int workspaceActiveDot: 10

    // Intentionally boxy.
    readonly property int radius: 0

    readonly property int animationInstant: 70
    readonly property int animationFast: 110
    readonly property int animationNormal: 170
    readonly property int animationDeliberate: 240
    readonly property int animationExit: 105

    readonly property real disabledOpacity: 0.55
    readonly property real secondaryOpacity: 0.72
    readonly property real normalOpacity: 1.0
}
