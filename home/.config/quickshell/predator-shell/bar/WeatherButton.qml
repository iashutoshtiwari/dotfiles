import QtQuick
import Quickshell

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

    implicitWidth: row.implicitWidth + 12
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? Theme.surface0 : "transparent"
        radius: Theme.radius
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: WeatherService.conditionIcon
            font.family: Theme.shellFont
            font.pixelSize: 13
            color: Theme.lavender
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: WeatherService.available
                ? Math.round(WeatherService.temperature) + "°C"
                : "--°C"
            font.family: Theme.shellFont
            font.pixelSize: 12
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
