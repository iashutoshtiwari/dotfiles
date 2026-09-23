import QtQuick
import Quickshell
import Quickshell.Io

import qs.theme
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

    implicitWidth: Theme.popupCompact
    implicitHeight: 336

    color: "transparent"
    grabFocus: true

    property bool confirmReboot: false
    property bool confirmShutdown: false

    onVisibleChanged: {
        if (!visible) {
            confirmReboot = false;
            confirmShutdown = false;
        }
    }

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            root.visible = !root.visible;
        }

        function open(): void {
            root.visible = true;
        }

        function close(): void {
            root.visible = false;
        }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        Column {
            anchors {
                fill: parent
                margins: 14
            }
            spacing: 10

            // HEADER
            Row {
                width: parent.width

                Column {
                    width: parent.width - 24
                    spacing: 2

                    Text {
                        text: "SESSION"
                        font.family: Theme.appFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: "ashutosh · ghost"
                        font.family: Theme.appFont
                        font.pixelSize: 10
                        color: Theme.subtext0
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSmall
                    color: closeMouse.containsMouse ? Theme.red : Theme.subtext0
                    text: "󰅖"

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.visible = false
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            // ACTIONS
            Column {
                width: parent.width
                spacing: 6

                // 1. LOCK SESSION
                Rectangle {
                    width: parent.width
                    height: 42
                    color: lockMouse.containsMouse ? Theme.surface0 : Theme.mantle
                    border.width: 1
                    border.color: lockMouse.containsMouse ? Theme.lavender : Theme.surface0
                    radius: Theme.radius

                    Row {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                            color: Theme.lavender
                            text: "󰌾"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 28 - lockHint.width
                            spacing: 1

                            Text {
                                text: "Lock Session"
                                font.family: Theme.appFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }

                            Text {
                                text: "Hyprlock screen lock"
                                font.family: Theme.appFont
                                font.pixelSize: 9
                                color: Theme.subtext0
                            }
                        }

                        Text {
                            id: lockHint
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.monoFont
                            font.pixelSize: 9
                            color: Theme.overlay1
                            text: "Super+Esc"
                        }
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["loginctl", "lock-session"]);
                            root.visible = false;
                        }
                    }
                }

                // 2. SUSPEND
                Rectangle {
                    width: parent.width
                    height: 42
                    color: suspendMouse.containsMouse ? Theme.surface0 : Theme.mantle
                    border.width: 1
                    border.color: suspendMouse.containsMouse ? Theme.lavender : Theme.surface0
                    radius: Theme.radius

                    Row {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                            color: Theme.lavender
                            text: "󰤄"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "Suspend"
                                font.family: Theme.appFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }

                            Text {
                                text: "Sleep system to RAM"
                                font.family: Theme.appFont
                                font.pixelSize: 9
                                color: Theme.subtext0
                            }
                        }
                    }

                    MouseArea {
                        id: suspendMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["systemctl", "suspend"]);
                            root.visible = false;
                        }
                    }
                }

                // 3. LOG OUT
                Rectangle {
                    width: parent.width
                    height: 42
                    color: logoutMouse.containsMouse ? Theme.surface0 : Theme.mantle
                    border.width: 1
                    border.color: logoutMouse.containsMouse ? Theme.lavender : Theme.surface0
                    radius: Theme.radius

                    Row {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                            color: Theme.peach
                            text: "󰗽"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "Log Out"
                                font.family: Theme.appFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }

                            Text {
                                text: "Terminate UWSM graphical session"
                                font.family: Theme.appFont
                                font.pixelSize: 9
                                color: Theme.subtext0
                            }
                        }
                    }

                    MouseArea {
                        id: logoutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["uwsm", "stop"]);
                            root.visible = false;
                        }
                    }
                }

                // 4. RESTART
                Rectangle {
                    width: parent.width
                    height: 42
                    color: root.confirmReboot
                        ? Theme.red
                        : (rebootMouse.containsMouse ? Theme.surface0 : Theme.mantle)
                    border.width: 1
                    border.color: root.confirmReboot ? Theme.red : (rebootMouse.containsMouse ? Theme.peach : Theme.surface0)
                    radius: Theme.radius

                    Row {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                            color: root.confirmReboot ? Theme.crust : Theme.peach
                            text: "󰜉"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: root.confirmReboot ? "Confirm Restart?" : "Restart"
                                font.family: Theme.appFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: root.confirmReboot ? Theme.crust : Theme.text
                            }

                            Text {
                                text: root.confirmReboot ? "Click again to reboot now" : "Reboot computer"
                                font.family: Theme.appFont
                                font.pixelSize: 9
                                color: root.confirmReboot ? Theme.crust : Theme.subtext0
                            }
                        }
                    }

                    MouseArea {
                        id: rebootMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.confirmReboot) {
                                Quickshell.execDetached(["systemctl", "reboot"]);
                                root.visible = false;
                            } else {
                                root.confirmReboot = true;
                                root.confirmShutdown = false;
                            }
                        }
                    }
                }

                // 5. SHUT DOWN
                Rectangle {
                    width: parent.width
                    height: 42
                    color: root.confirmShutdown
                        ? Theme.red
                        : (shutdownMouse.containsMouse ? Theme.surface0 : Theme.mantle)
                    border.width: 1
                    border.color: root.confirmShutdown ? Theme.red : (shutdownMouse.containsMouse ? Theme.red : Theme.surface0)
                    radius: Theme.radius

                    Row {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                            color: root.confirmShutdown ? Theme.crust : Theme.red
                            text: "󰐥"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: root.confirmShutdown ? "Confirm Shut Down?" : "Shut Down"
                                font.family: Theme.appFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: root.confirmShutdown ? Theme.crust : Theme.text
                            }

                            Text {
                                text: root.confirmShutdown ? "Click again to power off now" : "Power off computer"
                                font.family: Theme.appFont
                                font.pixelSize: 9
                                color: root.confirmShutdown ? Theme.crust : Theme.subtext0
                            }
                        }
                    }

                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.confirmShutdown) {
                                Quickshell.execDetached(["systemctl", "poweroff"]);
                                root.visible = false;
                            } else {
                                root.confirmShutdown = true;
                                root.confirmReboot = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
