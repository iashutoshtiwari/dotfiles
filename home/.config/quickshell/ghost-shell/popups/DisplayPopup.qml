import QtQuick
import Quickshell

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root

    property Item anchorItem

    signal openWallpaperPicker()

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: Theme.popupStandard
    implicitHeight: Math.ceil((content.implicitHeight + 32) / 4) * 4

    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (visible) {
            BrightnessService.refresh();
            KeyboardBacklightService.refresh(false);
        }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        Column {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }

            spacing: 12

            // ── 1. DISPLAY BRIGHTNESS ─────────────────────────────────
            SectionHeader {
                width: parent.width
                title: "DISPLAY"
                icon: "󰃠"
                value: BrightnessService.brightnessPercent + "%"
            }

            VolumeSlider {
                width: parent.width
                value: BrightnessService.brightnessPercent / 100
                onUserChanged: value => {
                    BrightnessService.setPercent(Math.round(value * 100));
                }
            }

            SegmentedControl {
                width: parent.width
                compact: true
                fontFamily: Theme.monoFont
                model: [
                    { label: "25%", value: 25 },
                    { label: "50%", value: 50 },
                    { label: "75%", value: 75 },
                    { label: "100%", value: 100 }
                ]
                currentValue: BrightnessService.brightnessPercent
                onSelected: val => BrightnessService.setPercent(val)
            }

            Divider { width: parent.width }

            // ── 2. KEYBOARD BACKLIGHT ──────────────────────────────────
            Column {
                width: parent.width
                spacing: 10
                visible: KeyboardBacklightService.available

                SectionHeader {
                    width: parent.width
                    title: "KEYBOARD BACKLIGHT"
                    icon: "󰌌"
                    iconColor: KeyboardBacklightService.brightness > 0 ? Theme.lavender : Theme.overlay1
                    value: {
                        if (KeyboardBacklightService.maximum === 2) {
                            if (KeyboardBacklightService.brightness === 0)
                                return "Off";
                            if (KeyboardBacklightService.brightness === 1)
                                return "Low";
                            return "High";
                        }
                        return KeyboardBacklightService.brightness + " / " + KeyboardBacklightService.maximum;
                    }
                    valueColor: KeyboardBacklightService.brightness > 0 ? Theme.lavender : Theme.subtext0
                }

                DiscreteSlider {
                    width: parent.width
                    value: KeyboardBacklightService.brightness
                    maximum: KeyboardBacklightService.maximum
                    stepLabels: KeyboardBacklightService.maximum === 2 ? ["Off", "Low", "High"] : []
                    onUserChanged: step => KeyboardBacklightService.setLevel(step)
                    onUserIncreased: KeyboardBacklightService.increase()
                    onUserDecreased: KeyboardBacklightService.decrease()
                }

                Divider { width: parent.width }
            }

            // ── 3. NIGHT LIGHT ─────────────────────────────────────────
            ToggleRow {
                width: parent.width
                label: "NIGHT LIGHT"
                description: NightLightService.statusText
                checked: NightLightService.enabled
                activeColor: Theme.peach
                onToggled: NightLightService.toggle()
            }

            Column {
                width: parent.width
                spacing: 8
                visible: NightLightService.available

                ValueLabel {
                    width: parent.width
                    label: "Color Temperature"
                    value: NightLightService.temperature + "K"
                    valueColor: Theme.peach
                }

                VolumeSlider {
                    width: parent.width
                    accentColor: Theme.peach
                    // Map 2000K..6500K -> 0.0..1.0
                    value: (NightLightService.temperature - 2000) / 4500
                    onUserChanged: value => {
                        NightLightService.setTemperature(Math.round(2000 + value * 4500));
                    }
                }

                SegmentedControl {
                    width: parent.width
                    compact: true
                    accentColor: Theme.peach
                    model: [
                        { label: "Cool", value: 6000 },
                        { label: "Warm", value: 4500 },
                        { label: "Cozy", value: 3500 },
                        { label: "Candle", value: 2500 }
                    ]
                    currentValue: NightLightService.temperature
                    onSelected: temp => {
                        NightLightService.setTemperature(temp);
                        if (!NightLightService.enabled)
                            NightLightService.setEnabled(true);
                    }
                }

                ToggleRow {
                    width: parent.width
                    label: "Schedule: 20:00 – 07:00"
                    checked: NightLightService.scheduleEnabled
                    isSwitch: false
                    onToggled: NightLightService.setScheduleEnabled(!NightLightService.scheduleEnabled)
                }
            }

            Divider { width: parent.width }

            // ── 4. WALLPAPER ───────────────────────────────────────────
            Item {
                width: parent.width
                height: 32

                SectionHeader {
                    anchors {
                        left: parent.left
                        right: galleryBtn.left
                        rightMargin: Theme.spacingSm
                        verticalCenter: parent.verticalCenter
                    }
                    title: "WALLPAPER"
                    subtitle: WallpaperService.currentWallpaperName || "Default"
                    icon: "󰸉"
                }

                ControlButton {
                    id: galleryBtn
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    compact: true
                    icon: "󰸉"
                    text: "Gallery"
                    onClicked: {
                        root.openWallpaperPicker();
                        root.visible = false;
                    }
                }
            }
        }
    }
}
