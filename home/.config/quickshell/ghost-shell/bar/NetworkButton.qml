import QtQuick

import qs.theme
import qs.services
import qs.components

Item {
    id: root

    signal clicked()
    property bool active: false

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
    BarButtonBackground { anchors.fill: parent; active: root.active; hovered: mouse.containsMouse; pressed: mouse.pressed }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: root.active ? Theme.lavender : NetworkService.connected
            ? Theme.text
            : Theme.overlay1
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()
    }
}
