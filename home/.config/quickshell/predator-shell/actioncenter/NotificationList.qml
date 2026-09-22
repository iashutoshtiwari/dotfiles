// NotificationList.qml
// Notification section inside the Action Center drawer.
// Contains section header, Clear All, empty state, and scrollable notification rows.
// Future sections (Bluetooth, Displays, etc.) sit above this in ActionCenter.qml.

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.theme
import qs.services

Item {
    id: root

    // Whether the action center drawer is currently open (used to reset scroll)
    property bool drawerOpen: false

    readonly property int notifCount: NotificationService.trackedNotifications?.values?.length ?? 0

    implicitWidth: 392

    // Reset scroll position to top when drawer opens so newest notifications show.
    onDrawerOpenChanged: {
        if (drawerOpen)
            notifList.positionViewAtBeginning();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Section header ──────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingMd
            Layout.topMargin: Theme.spacingSm
            Layout.bottomMargin: Theme.spacingSm

            Text {
                Layout.fillWidth: true
                text: "Notifications"
                font.family: Theme.appFont
                font.pixelSize: Theme.textSmall
                font.weight: Font.DemiBold
                color: Theme.subtext0
                font.letterSpacing: 0.5
            }

            // Clear All — only visible when there are notifications
            Text {
                visible: root.notifCount > 0
                text: "Clear all"
                font.family: Theme.appFont
                font.pixelSize: Theme.textSmall
                color: clearMouse.containsMouse ? Theme.text : Theme.subtext0
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    anchors.margins: -8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.clearAll()
                }
            }
        }

        // ── Divider below section header ────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingMd
            height: 1
            color: Theme.surface0
        }

        // ── Empty state ─────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.notifCount === 0

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingSm

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰂚"
                    font.family: Theme.shellFont
                    font.pixelSize: 28
                    color: Theme.overlay0
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "You're all caught up"
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textBody
                    color: Theme.overlay1
                }
            }
        }

        // ── Scrollable notification list ────────────────────────────────
        ListView {
            id: notifList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.notifCount > 0
            clip: true
            spacing: 0
            model: NotificationService.trackedNotifications

            // Scrollbar — subtle, only visible while scrolling
            ScrollBar.vertical: ScrollBar {
                id: vScrollBar
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 3
                    color: Theme.overlay0
                    opacity: vScrollBar.active ? 0.7 : 0
                    Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                }
                background: Item {}
            }

            // New notification entrance
            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        from: 0; to: 1
                        duration: Theme.motionNormal
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "y"
                        from: Theme.reducedMotion ? 0 : -6
                        to: 0
                        duration: Theme.motionNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Notification dismissal
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: Theme.motionExit
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "x"
                        to: Theme.reducedMotion ? 0 : 16
                        duration: Theme.motionExit
                        easing.type: Easing.InCubic
                    }
                }
            }

            // Remaining notifications reflow smoothly upward
            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: Theme.motionNormal
                    easing.type: Easing.OutCubic
                }
            }

            delegate: NotificationCard {
                id: card
                required property var modelData
                width: notifList.width
                notif: card.modelData
                onDismissRequested: NotificationService.dismiss(card.modelData)

                // Subtle bottom divider between notifications
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    anchors.leftMargin: Theme.spacingMd
                    anchors.rightMargin: Theme.spacingMd
                    height: 1
                    color: Theme.surface0
                    visible: card.modelData !== null
                }
            }
        }
    }
}
