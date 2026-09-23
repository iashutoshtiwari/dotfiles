import QtQuick

import qs.theme
import qs.components

Item {
    id: root

    signal clicked()
    property bool active: false

    implicitWidth: 34
    implicitHeight: 28

    BarButtonBackground {
        id: bg
        anchors.fill: parent
        active: root.active
        hovered: mouseArea.containsMouse
        pressed: mouseArea.pressed

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconNormal
            color: root.active ? Theme.lavender : mouseArea.containsMouse ? Theme.red : Theme.subtext1
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
