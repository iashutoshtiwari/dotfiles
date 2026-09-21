import QtQuick
import Quickshell

import qs.theme
import qs.components

Item {
    id: root

    signal clicked()
    property bool active: false

    implicitWidth: 58
    implicitHeight: 28

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    BarButtonBackground { anchors.fill: parent; active: root.active; hovered: mouse.containsMouse; pressed: mouse.pressed }

    Text {
        anchors.centerIn: parent

        text: Qt.formatDateTime(clock.date, "hh:mm")

        font.family: Theme.appFont
        font.pixelSize: 13
        font.weight: Font.DemiBold

        color: root.active ? Theme.lavender : Theme.text
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()
    }
}
