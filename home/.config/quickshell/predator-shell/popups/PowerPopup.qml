import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs.theme
import qs.services

PopupWindow {
    id: root

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

    implicitWidth: 370
    implicitHeight: 405

    color: "transparent"
    grabFocus: true

    Rectangle {
        anchors.fill: parent

        color: Theme.base
        border.width: 1
        border.color: Theme.surface0

        Column {
            anchors {
                fill: parent
                margins: 16
            }

            spacing: 14

            Row {
                width: parent.width

                Text {
                    width: parent.width - 80

                    text: "POWER"

                    font.family: Theme.shellFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold

                    color: Theme.text
                }

                Text {
                    width: 80

                    horizontalAlignment: Text.AlignRight

                    text:
                        Math.round(PowerService.percentage)
                        + "%"

                    font.family: Theme.shellFont
                    font.pixelSize: 13
                    font.weight: Font.DemiBold

                    color: PowerService.charging
                        ? Theme.green
                        : Theme.lavender
                }
            }

            Rectangle {
                width: parent.width
                height: 5

                color: Theme.surface1

                Rectangle {
                    width:
                        parent.width
                        * Math.max(
                            0,
                            Math.min(
                                1,
                                PowerService.percentage / 100
                            )
                        )

                    height: parent.height

                    color: PowerService.charging
                        ? Theme.green
                        : Theme.lavender
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: PowerService.statusText

                    font.family: Theme.shellFont
                    font.pixelSize: 11
                    font.weight: Font.DemiBold

                    color: Theme.text
                }

                Text {
                    visible:
                        PowerService.timeRemaining > 0

                    text: PowerService.charging
                        ? PowerService.formatDuration(
                            PowerService.timeRemaining
                        ) + " until full"
                        : PowerService.formatDuration(
                            PowerService.timeRemaining
                        ) + " remaining"

                    font.family: Theme.shellFont
                    font.pixelSize: 10

                    color: Theme.subtext0
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            Grid {
                width: parent.width

                columns: 2
                columnSpacing: 12
                rowSpacing: 7

                Text {
                    width: 120
                    text: "POWER SOURCE"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.overlay1
                }

                Text {
                    width: 190

                    text: PowerService.rateText

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.subtext1
                }

                Text {
                    width: 120
                    text: "DRAW / CHARGE"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.overlay1
                }

                Text {
                    width: 190

                    text:
                        PowerService.powerRate > 0
                        ? PowerService.powerRate.toFixed(1)
                            + " W"
                        : "—"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.subtext1
                }

                Text {
                    width: 120
                    text: "ENERGY"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.overlay1
                }

                Text {
                    width: 190

                    text:
                        PowerService.energy.toFixed(1)
                        + " / "
                        + PowerService.capacity.toFixed(1)
                        + " Wh"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.subtext1
                }

                Text {
                    width: 120
                    text: "BATTERY HEALTH"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.overlay1
                }

                Text {
                    width: 190

                    text:
                        PowerService.healthAvailable
                        ? Math.round(
                            PowerService.health
                        ) + "%"
                        : "Not reported"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    color: Theme.subtext1
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            Text {
                text: "POWER PROFILE"

                font.family: Theme.shellFont
                font.pixelSize: 9
                font.weight: Font.DemiBold

                color: Theme.overlay1
            }

            Row {
                width: parent.width
                spacing: 5

                Repeater {
                    model: [
                        {
                            label: "SAVE",
                            profile: PowerProfile.PowerSaver,
                            available: true
                        },
                        {
                            label: "BALANCED",
                            profile: PowerProfile.Balanced,
                            available: true
                        },
                        {
                            label: "PERFORMANCE",
                            profile: PowerProfile.Performance,
                            available:
                                PowerService.performanceAvailable
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        width:
                            (parent.width - 10) / 3

                        height: 36

                        color:
                            PowerService.profile
                                === modelData.profile
                            ? Theme.lavender
                            : Theme.mantle

                        border.width: 1

                        border.color:
                            PowerService.profile
                                === modelData.profile
                            ? Theme.lavender
                            : Theme.surface0

                        opacity:
                            modelData.available
                            ? 1.0
                            : 0.35

                        Text {
                            anchors.centerIn: parent

                            text: modelData.label

                            font.family: Theme.shellFont
                            font.pixelSize: 9
                            font.weight: Font.DemiBold

                            color:
                                PowerService.profile
                                    === modelData.profile
                                ? Theme.crust
                                : Theme.text
                        }

                        MouseArea {
                            anchors.fill: parent

                            enabled:
                                parent.modelData.available

                            cursorShape:
                                enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                            onClicked:
                                PowerService.setProfile(
                                    parent.modelData.profile
                                )
                        }
                    }
                }
            }

            Text {
                text:
                    "TLP · " + PowerService.profileName

                font.family: Theme.shellFont
                font.pixelSize: 9

                color: Theme.overlay1
            }
        }
    }
}
