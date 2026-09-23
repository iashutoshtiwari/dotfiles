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

    // Typography
    // Inter carries human-readable UI, while JetBrains Mono is reserved for
    // technical readouts, percentages, hardware states, and Nerd Font icons.
    readonly property string uiFont: "Inter"
    readonly property string appFont: uiFont
    readonly property string monoFont: "JetBrainsMono Nerd Font"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    // Keep shellFont alias for compatibility
    readonly property string shellFont: monoFont

    // Typography Scale
    readonly property int fontCaption: 10
    readonly property int fontBody: 12
    readonly property int fontBodyStrong: 12
    readonly property int fontValue: 13
    readonly property int fontHeading: 15
    readonly property int fontDisplay: 28

    // Aliases for compatibility
    readonly property int textSmall: fontCaption
    readonly property int textCaption: fontCaption
    readonly property int textBody: fontBody
    readonly property int textBodyStrong: fontBodyStrong
    readonly property int textValue: fontValue
    readonly property int textHeading: fontHeading
    readonly property int textDisplay: fontDisplay

    // Icon sizes
    readonly property int iconSmall: 12
    readonly property int iconNormal: 15
    readonly property int iconLarge: 24

    // Control sizes
    readonly property int controlCompact: 24
    readonly property int controlNormal: 32
    readonly property int controlLarge: 40

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

    // Action Center drawer width (360–420px range, using popupWide value)
    readonly property int actionCenterWidth: 392

    // Shared shell geometry. Keep surfaces square; circular geometry belongs to
    // indicators whose shape communicates a point or status.
    readonly property int surfaceBorder: 1
    readonly property int activeRail: 2
    readonly property int borderWidth: surfaceBorder
    readonly property int activeBorderWidth: activeRail
    readonly property int workspaceSlot: 31
    readonly property int workspaceDot: 8
    readonly property int workspaceActiveDot: 10

    // Intentionally boxy.
    readonly property int radius: 0

    // Motion is centralized so interaction feedback, spatial movement, and
    // exits share one cadence. Reduced motion retains only short fades.
    readonly property bool reducedMotion: false
    readonly property int motionMicro: reducedMotion ? 60 : 80
    readonly property int motionFast: reducedMotion ? 70 : 100
    readonly property int motionToggle: reducedMotion ? 70 : 130
    readonly property int motionNormal: reducedMotion ? 80 : 170
    readonly property int motionSpatial: reducedMotion ? 90 : 230
    readonly property int motionExitFast: reducedMotion ? 60 : 90
    readonly property int motionExit: reducedMotion ? 70 : 110

    readonly property real disabledOpacity: 0.55
    readonly property real secondaryOpacity: 0.72
    readonly property real normalOpacity: 1.0
    readonly property real backdropOpacity: 0.28
    readonly property real highlightOpacity: 0.12
}
