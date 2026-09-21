import QtQuick

import qs.theme

Item {
    id: root

    signal clicked()

    implicitWidth: 34
    implicitHeight: 28

    Rectangle {
        id: bg
        anchors.fill: parent
        color: mouseArea.containsMouse ? Theme.surface0 : "transparent"
        radius: Theme.radius

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            font.family: Theme.shellFont
            font.pixelSize: 15
            color: mouseArea.containsMouse ? Theme.red : Theme.lavender
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
