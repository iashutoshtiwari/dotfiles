import QtQuick
import Quickshell

import qs.theme
import qs.services
import qs.components

Item {
    id: root

    signal clicked()
    property bool active: false

    implicitWidth: row.implicitWidth + 12
    implicitHeight: 28

    BarButtonBackground {
        anchors.fill: parent
        active: root.active
        hovered: mouseArea.containsMouse
        pressed: mouseArea.pressed
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: WeatherService.conditionIcon
            font.family: Theme.iconFont
            font.pixelSize: 13
            color: root.active ? Theme.text : Theme.lavender
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: WeatherService.available
                ? Math.round(WeatherService.temperature) + "°C"
                : "--°C"
            font.family: Theme.monoFont
            font.pixelSize: Theme.fontBody
            font.weight: Font.Medium
            color: Theme.text
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
