import QtQuick
import Quickshell

import qs.theme

Item {
    id: root

    signal clicked()

    implicitWidth: 58
    implicitHeight: 28

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent

        text: Qt.formatDateTime(clock.date, "hh:mm")

        font.family: Theme.shellFont
        font.pixelSize: 13
        font.weight: Font.DemiBold

        color: Theme.text
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
