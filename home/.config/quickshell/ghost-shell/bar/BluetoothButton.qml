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
        if (!BluetoothService.available)
            return "󰂲";

        if (!BluetoothService.enabled)
            return "󰂲";

        if (BluetoothService.connectedCount > 0)
            return "󰂱";

        return "󰂯";
    }
    BarButtonBackground { anchors.fill: parent; active: root.active; hovered: mouse.containsMouse; pressed: mouse.pressed }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.iconFont
        font.pixelSize: Theme.iconNormal

        color: {
            if (root.active)
                return Theme.lavender;
            if (!BluetoothService.enabled)
                return Theme.overlay1;

            if (BluetoothService.connectedCount > 0)
                return Theme.lavender;

            return Theme.text;
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()
    }
}
