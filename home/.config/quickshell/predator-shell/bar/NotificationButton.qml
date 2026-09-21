import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

    implicitWidth: NotificationService.unreadCount > 0 ? 46 : 34
    implicitHeight: 28

    Row {
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: NotificationService.dnd ? "󰂛" : "󰂚"
            font.family: Theme.shellFont
            font.pixelSize: 15
            color: NotificationService.dnd
                ? Theme.red
                : (NotificationService.unreadCount > 0 ? Theme.lavender : Theme.subtext0)
        }

        // Unread count pill badge
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: NotificationService.unreadCount > 0
            width: Math.max(14, badgeText.implicitWidth + 6)
            height: 14
            color: Theme.lavender
            radius: Theme.radius

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: NotificationService.unreadCount > 99 ? "99+" : NotificationService.unreadCount.toString()
                font.family: Theme.shellFont
                font.pixelSize: 9
                font.weight: Font.Bold
                color: Theme.crust
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
