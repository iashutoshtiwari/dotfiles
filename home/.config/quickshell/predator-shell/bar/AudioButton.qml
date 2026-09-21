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
        if (AudioService.outputMuted)
            return "󰖁";

        if (AudioService.outputVolume < 0.01)
            return "󰕿";

        if (AudioService.outputVolume < 0.5)
            return "󰖀";

        return "󰕾";
    }

    BarButtonBackground {
        anchors.fill: parent
        active: root.active
        hovered: mouse.containsMouse
        pressed: mouse.pressed
    }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: root.active ? Theme.lavender : AudioService.outputMuted
            ? Theme.overlay1
            : Theme.text
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()

        onWheel: wheel => {
            const step = wheel.angleDelta.y > 0
                ? 0.05
                : -0.05;

            AudioService.setOutputVolume(
                AudioService.outputVolume + step
            );
        }
    }
}
