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

    Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 2
        color: Theme.lavender
        opacity: root.active ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: root.active ? Theme.motionToggle : Theme.motionExitFast
                easing.type: root.active ? Easing.OutCubic : Easing.InCubic
            }
        }
    }
}
