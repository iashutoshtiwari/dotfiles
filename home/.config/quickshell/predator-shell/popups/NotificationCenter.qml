import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.theme
import qs.services

PopupWindow {
    id: root

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

    implicitWidth: 360
    implicitHeight: 480

    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (visible) {
            NotificationService.markAllRead();
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.base
        border.width: 1
        border.color: Theme.surface0
        radius: Theme.radius

        Column {
            anchors {
                fill: parent
                margins: 14
            }
            spacing: 10

            // HEADER ROW
            Row {
                width: parent.width

                Text {
                    width: parent.width - actionButtons.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: "NOTIFICATIONS"
                    font.family: Theme.shellFont
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                Row {
                    id: actionButtons
                    spacing: 6

                    // DND BUTTON
                    Rectangle {
                        implicitWidth: dndText.implicitWidth + 12
                        height: 24
                        color: NotificationService.dnd ? Theme.red : dndMouse.containsMouse ? Theme.surface1 : Theme.surface0
                        radius: Theme.radius

                        Text {
                            id: dndText
                            anchors.centerIn: parent
                            text: NotificationService.dnd ? "󰂛 DND" : "󰂚 DND"
                            font.family: Theme.shellFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: NotificationService.dnd ? Theme.crust : Theme.text
                        }

                        MouseArea {
                            id: dndMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.toggleDnd()
                        }
                    }

                    // CLEAR ALL BUTTON
                    Rectangle {
                        implicitWidth: clearText.implicitWidth + 12
                        height: 24
                        color: clearMouse.containsMouse ? Theme.surface1 : Theme.surface0
                        radius: Theme.radius
                        visible: NotificationService.trackedNotifications && NotificationService.trackedNotifications.values.length > 0

                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "󰎟 Clear"
                            font.family: Theme.shellFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Theme.subtext0
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.clearAll()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            // NOTIFICATION LIST OR EMPTY STATE
            Item {
                width: parent.width
                height: parent.height - 42

                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: !NotificationService.trackedNotifications || NotificationService.trackedNotifications.values.length === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Theme.shellFont
                        font.pixelSize: 32
                        color: Theme.surface2
                        text: "󰂚"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Theme.shellFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.subtext0
                        text: "No Notifications"
                    }
                }

                // List view
                ListView {
                    id: listView
                    anchors.fill: parent
                    clip: true
                    spacing: 8
                    visible: NotificationService.trackedNotifications && NotificationService.trackedNotifications.values.length > 0

                    model: NotificationService.trackedNotifications

                    delegate: Rectangle {
                        id: notifCard
                        required property var modelData

                        width: listView.width
                        implicitHeight: cardCol.implicitHeight + 16

                        color: Theme.mantle
                        border.width: 1
                        border.color: Theme.surface0
                        radius: Theme.radius

                        // Left urgency accent
                        Rectangle {
                            width: 3
                            height: parent.height
                            color: notifCard.modelData && notifCard.modelData.urgency === 2
                                ? Theme.red
                                : (notifCard.modelData && notifCard.modelData.urgency === 1 ? Theme.lavender : Theme.surface2)
                        }

                        Column {
                            id: cardCol
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 8
                                leftMargin: 12
                            }
                            spacing: 4

                            // Top row: App Name + Dismiss button
                            Row {
                                width: parent.width

                                Row {
                                    width: parent.width - 20
                                    spacing: 6

                                    IconImage {
                                        width: 14
                                        height: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: notifCard.modelData && notifCard.modelData.appIcon
                                            ? Quickshell.iconPath(notifCard.modelData.appIcon)
                                            : ""
                                        visible: status === Image.Ready
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.family: Theme.shellFont
                                        font.pixelSize: 9
                                        font.weight: Font.DemiBold
                                        color: Theme.lavender
                                        text: (notifCard.modelData && notifCard.modelData.appName) || "Notification"
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    font.family: Theme.shellFont
                                    font.pixelSize: 11
                                    color: itemCloseMouse.containsMouse ? Theme.red : Theme.subtext0
                                    text: "󰅖"

                                    MouseArea {
                                        id: itemCloseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (notifCard.modelData)
                                                notifCard.modelData.dismiss();
                                        }
                                    }
                                }
                            }

                            // Summary
                            Text {
                                width: parent.width
                                font.family: Theme.shellFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                                text: (notifCard.modelData && notifCard.modelData.summary) || ""
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            // Body
                            Text {
                                width: parent.width
                                font.family: Theme.shellFont
                                font.pixelSize: 10
                                color: Theme.subtext1
                                text: (notifCard.modelData && notifCard.modelData.body) || ""
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }

                            // Actions
                            Row {
                                width: parent.width
                                spacing: 6
                                visible: notifCard.modelData && notifCard.modelData.actions && notifCard.modelData.actions.length > 0

                                Repeater {
                                    model: (notifCard.modelData && notifCard.modelData.actions) || []

                                    delegate: Rectangle {
                                        id: actBtn
                                        required property var modelData

                                        implicitWidth: actLabel.implicitWidth + 12
                                        height: 20
                                        color: actMouse.containsMouse ? Theme.surface1 : Theme.surface0
                                        radius: Theme.radius

                                        Text {
                                            id: actLabel
                                            anchors.centerIn: parent
                                            font.family: Theme.shellFont
                                            font.pixelSize: 9
                                            font.weight: Font.DemiBold
                                            color: Theme.lavender
                                            text: (actBtn.modelData && actBtn.modelData.text) || ""
                                        }

                                        MouseArea {
                                            id: actMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (actBtn.modelData)
                                                    actBtn.modelData.invoke();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
