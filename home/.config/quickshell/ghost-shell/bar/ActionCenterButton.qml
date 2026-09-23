// ActionCenterButton.qml
// Bar button for the Action Center drawer — rightmost bar button.
//
// States:
//   NORMAL:  Subtext0 bell glyph
//   UNREAD:  Lavender bell + compact unread badge (capped at 99+)
//   DND:     Red muted-bell glyph
//   OPEN:    Lavender active treatment (matching other active bar buttons)
//
// The badge is compact and does not dramatically widen the button.

import QtQuick

import qs.theme
import qs.services
import qs.components

Item {
    id: root

    signal clicked()
    property bool active: false

    // Stable width: badge only adds a small amount so button geometry is predictable.
    implicitWidth: NotificationService.unreadCount > 0 ? 48 : 34
    implicitHeight: 28

    BarButtonBackground {
        anchors.fill: parent
        active: root.active
        hovered: mouse.containsMouse
        pressed: mouse.pressed
    }

    Row {
        anchors.centerIn: parent
        spacing: 4

        // Bell / notification-center glyph
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: NotificationService.dnd ? "󰂛" : "󰂚"
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconNormal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.active       ? Theme.lavender
                 : NotificationService.dnd    ? Theme.red
                 : NotificationService.unreadCount > 0 ? Theme.lavender
                 : Theme.subtext0

            Behavior on color { ColorAnimation { duration: Theme.motionFast } }
        }

        // Compact unread badge — no pill unless count makes it necessary
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: NotificationService.unreadCount > 0 && !root.active
            width: Math.max(14, badgeLabel.implicitWidth + 6)
            height: 14
            color: Theme.lavender
            radius: Theme.radius

            Text {
                id: badgeLabel
                anchors.centerIn: parent
                text: NotificationService.unreadCount > 99 ? "99+" : NotificationService.unreadCount.toString()
                font.family: Theme.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                color: Theme.crust
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
