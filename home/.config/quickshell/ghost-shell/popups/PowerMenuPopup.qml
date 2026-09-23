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
            SectionHeader {
                width: parent.width
                title: "SESSION"
                subtitle: "ashutosh · ghost"

                IconButton {
                    icon: "󰅖"
                    danger: true
                    onClicked: root.visible = false
                }
            }

            Divider { width: parent.width }

            // ACTIONS
            Column {
                width: parent.width
                spacing: 6

                // 1. LOCK SESSION
                ControlRow {
                    width: parent.width
                    icon: "󰌾"
                    iconColor: Theme.lavender
                    title: "Lock Session"
                    description: "Lock the current session"
                    shortcut: "Super+Esc"
                    onClicked: {
                        Quickshell.execDetached(["loginctl", "lock-session"]);
                        root.visible = false;
                    }
                }

                // 2. SUSPEND
                ControlRow {
                    width: parent.width
                    icon: "󰤄"
                    iconColor: Theme.sapphire
                    title: "Suspend"
                    description: "Sleep to RAM"
                    onClicked: {
                        Quickshell.execDetached(["systemctl", "suspend"]);
                        root.visible = false;
                    }
                }

                // 3. HIBERNATE
                ControlRow {
                    width: parent.width
                    icon: "󰒲"
                    iconColor: Theme.mauve
                    title: "Hibernate"
                    description: "Save state and power off"
                    onClicked: {
                        Quickshell.execDetached(["systemctl", "hibernate"]);
                        root.visible = false;
                    }
                }

                // 4. RESTART
                ControlRow {
                    width: parent.width
                    icon: "󰜉"
                    iconColor: Theme.peach
                    title: root.confirmReboot ? "Confirm Restart?" : "Restart"
                    description: root.confirmReboot ? "Click again to reboot now" : "Reboot computer"
                    danger: true
                    active: root.confirmReboot
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

                // 5. SHUT DOWN
                ControlRow {
                    width: parent.width
                    icon: "󰐥"
                    iconColor: Theme.red
                    title: root.confirmShutdown ? "Confirm Shut Down?" : "Shut Down"
                    description: root.confirmShutdown ? "Click again to power off now" : "Power off computer"
                    danger: true
                    active: root.confirmShutdown
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
