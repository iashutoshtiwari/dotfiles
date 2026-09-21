import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

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

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: AudioService.outputMuted
            ? Theme.overlay1
            : Theme.text
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

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
