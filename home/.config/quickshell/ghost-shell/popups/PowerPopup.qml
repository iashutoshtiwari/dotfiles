import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root
    property Item anchorItem

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
    implicitHeight: 408
    color: "transparent"
    grabFocus: true

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spacingMd

            PopupHeader {
                Layout.fillWidth: true
                icon: PowerService.charging ? "󰂄" : "󰁹"
                title: "Battery"
                subtitle: !PowerService.ready ? "Battery information unavailable"
                    : Math.round(PowerService.percentage) + "% · "
                        + (PowerService.timeRemaining > 0
                            ? PowerService.formatDuration(PowerService.timeRemaining)
                                + (PowerService.charging ? " until full" : " remaining")
                            : PowerService.statusText)
            }

            Divider { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingLg
                ColumnLayout {
                    spacing: 0
                    Text {
                        text: Math.round(PowerService.percentage) + "%"
                        font.family: Theme.monoFont
                        font.pixelSize: Theme.fontDisplay
                        font.weight: Font.DemiBold
                        color: PowerService.charging ? Theme.green : Theme.text
                    }
                    Text {
                        text: PowerService.statusText
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontCaption
                        color: Theme.subtext0
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        text: PowerService.rateText
                        font.family: Theme.monoFont
                        font.pixelSize: Theme.fontBody
                        color: Theme.subtext1
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        color: Theme.surface1
                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, PowerService.percentage / 100))
                            height: parent.height
                            color: PowerService.charging ? Theme.green : Theme.lavender
                        }
                    }
                }
            }

            SectionHeader {
                title: "POWER MODE"
            }

            SegmentedControl {
                Layout.fillWidth: true
                model: [
                    { label: "Power Saver", value: PowerProfile.PowerSaver, available: true },
                    { label: "Balanced", value: PowerProfile.Balanced, available: true },
                    { label: "Performance", value: PowerProfile.Performance, available: PowerService.performanceAvailable }
                ]
                currentValue: PowerService.profile
                onSelected: val => PowerService.setProfile(val)
            }

            SectionHeader {
                title: "DEVICE DETAILS"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                ValueLabel {
                    Layout.fillWidth: true
                    label: "Power source"
                    value: PowerService.onBattery ? "Battery" : "AC adapter"
                    valueFont: Theme.appFont
                    valueColor: Theme.text
                }

                ValueLabel {
                    Layout.fillWidth: true
                    label: "Charge rate"
                    value: PowerService.rateText
                    valueFont: Theme.monoFont
                    valueColor: Theme.subtext1
                }

                ValueLabel {
                    Layout.fillWidth: true
                    label: "Energy"
                    value: PowerService.energy.toFixed(1) + " / " + PowerService.capacity.toFixed(1) + " Wh"
                    valueFont: Theme.monoFont
                    valueColor: Theme.text
                }

                ValueLabel {
                    Layout.fillWidth: true
                    label: "Battery health"
                    value: PowerService.healthAvailable ? Math.round(PowerService.health) + "%" : "Not reported"
                    valueFont: PowerService.healthAvailable ? Theme.monoFont : Theme.appFont
                    valueColor: Theme.text
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
