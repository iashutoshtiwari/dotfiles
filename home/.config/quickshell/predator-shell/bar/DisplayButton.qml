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
        if (NightLightService.enabled)
            return "󰛨";

        const pct = BrightnessService.brightnessPercent;
        if (pct >= 70)
            return "󰃠";
        if (pct >= 30)
            return "󰃟";
        return "󰃞";
    }
    BarButtonBackground { anchors.fill: parent; active: root.active; hovered: mouse.containsMouse; pressed: mouse.pressed }

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: Theme.shellFont
        font.pixelSize: 15

        color: root.active ? Theme.lavender : NightLightService.enabled
            ? Theme.peach
            : Theme.text
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                BrightnessService.increase(5);
            else if (wheel.angleDelta.y < 0)
                BrightnessService.decrease(5);
        }
    }
}
