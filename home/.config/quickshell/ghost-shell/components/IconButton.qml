import QtQuick

import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property color foreground: Theme.subtext1
    property color activeForeground: Theme.text
    property bool active: false

    signal clicked()

    implicitWidth: 30
    implicitHeight: 30
    color: mouse.pressed ? Theme.surface2
        : mouse.containsMouse || active ? Theme.surface1
        : "transparent"
    border.width: active ? Theme.surfaceBorder : 0
    border.color: active ? Theme.lavender : "transparent"
    radius: Theme.radius
    opacity: enabled ? 1 : Theme.disabledOpacity
    scale: mouse.pressed && !Theme.reducedMotion ? 0.98 : 1

    Behavior on color {
        ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
    }
    Behavior on scale { NumberAnimation { duration: Theme.motionMicro; easing.type: Easing.OutCubic } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.iconFont
        font.pixelSize: 14
        color: root.active ? Theme.lavender : root.foreground
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
