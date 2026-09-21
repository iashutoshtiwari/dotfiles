import QtQuick

import qs.theme

Rectangle {
    id: root

    property bool active: false
    property bool hovered: false
    property bool pressed: false

    color: pressed ? Theme.surface2
        : active ? Qt.rgba(Theme.lavender.r, Theme.lavender.g, Theme.lavender.b, 0.12)
        : hovered ? Theme.surface0
        : "transparent"
    radius: Theme.radius

    Behavior on color { ColorAnimation { duration: Theme.animationFast } }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 2
        color: Theme.lavender
        visible: root.active
    }
}
