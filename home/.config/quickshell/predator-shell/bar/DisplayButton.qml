import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

    implicitWidth: 34
    implicitHeight: 28

    readonly property string icon: {
        if (NightLightService.enabled)
            return "󰛨";

        const pct = BrightnessService.brightnessPercent;
        if (pct >= 70)
            return "󰃠";
        if (pct >= 30)
            return "󰃟";
        return "󰃞";
    }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: NightLightService.enabled
            ? Theme.peach
            : Theme.text
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                BrightnessService.increase(5);
            else if (wheel.angleDelta.y < 0)
                BrightnessService.decrease(5);
        }
    }
}
