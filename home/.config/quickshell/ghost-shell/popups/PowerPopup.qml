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

            SectionLabel { text: "Power mode" }
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: Theme.base
                border.width: 1
                border.color: Theme.surface1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Repeater {
                        model: [
                            { label: "Power Saver", profile: PowerProfile.PowerSaver, available: true },
                            { label: "Balanced", profile: PowerProfile.Balanced, available: true },
                            { label: "Performance", profile: PowerProfile.Performance, available: PowerService.performanceAvailable }
                        ]
                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: PowerService.profile === modelData.profile
                                ? Qt.rgba(Theme.lavender.r, Theme.lavender.g, Theme.lavender.b, 0.16)
                                : segmentMouse.containsMouse ? Theme.surface0 : "transparent"
                            opacity: modelData.available ? 1 : Theme.disabledOpacity
                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: Theme.activeRail
                                color: Theme.lavender
                                visible: PowerService.profile === parent.modelData.profile
                            }
                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData.label
                                font.family: Theme.appFont
                                font.pixelSize: Theme.fontCaption
                                font.weight: PowerService.profile === parent.modelData.profile ? Font.DemiBold : Font.Normal
                                color: PowerService.profile === parent.modelData.profile ? Theme.lavender : Theme.subtext1
                            }
                            MouseArea {
                                id: segmentMouse
                                anchors.fill: parent
                                enabled: parent.modelData.available
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: PowerService.setProfile(parent.modelData.profile)
                            }
                        }
                    }
                }
            }

            SectionLabel { text: "Device details" }
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Theme.spacingLg
                rowSpacing: Theme.spacingSm

                Repeater {
                    model: [
                        { label: "Power source", value: PowerService.onBattery ? "Battery" : "AC adapter", isMono: false },
                        { label: "Charge rate", value: PowerService.rateText, isMono: true },
                        { label: "Energy", value: PowerService.energy.toFixed(1) + " / " + PowerService.capacity.toFixed(1) + " Wh", isMono: true },
                        { label: "Battery health", value: PowerService.healthAvailable ? Math.round(PowerService.health) + "%" : "Not reported", isMono: PowerService.healthAvailable }
                    ]
                    RowLayout {
                        required property var modelData
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: parent.modelData.label
                            font.family: Theme.appFont
                            font.pixelSize: Theme.fontBody
                            color: Theme.subtext0
                        }
                        Text {
                            text: parent.modelData.value
                            font.family: parent.modelData.isMono ? Theme.monoFont : Theme.appFont
                            font.pixelSize: Theme.fontBody
                            color: Theme.text
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
