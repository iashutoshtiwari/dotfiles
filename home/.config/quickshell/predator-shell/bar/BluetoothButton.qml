import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

    implicitWidth: 34
    implicitHeight: 28

    readonly property string icon: {
        if (!BluetoothService.available)
            return "󰂲";

        if (!BluetoothService.enabled)
            return "󰂲";

        if (BluetoothService.connectedCount > 0)
            return "󰂱";

        return "󰂯";
    }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: {
            if (!BluetoothService.enabled)
                return Theme.overlay1;

            if (BluetoothService.connectedCount > 0)
                return Theme.lavender;

            return Theme.text;
        }
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
