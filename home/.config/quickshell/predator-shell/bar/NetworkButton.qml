import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

    implicitWidth: 34
    implicitHeight: 28

    readonly property string icon: {
        if (NetworkService.wiredConnected)
            return "󰈀";

        if (!NetworkService.wifiEnabled)
            return "󰤭";

        if (!NetworkService.wifiConnected)
            return "󰤮";

        const strength = NetworkService.signalStrength;

        if (strength >= 0.75)
            return "󰤨";
        if (strength >= 0.50)
            return "󰤥";
        if (strength >= 0.25)
            return "󰤢";

        return "󰤟";
    }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: NetworkService.connected
            ? Theme.text
            : Theme.overlay1
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
