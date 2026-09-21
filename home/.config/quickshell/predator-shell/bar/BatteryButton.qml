import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    signal clicked()

    implicitWidth: 72
    implicitHeight: 28

    readonly property string icon: {
        if (!PowerService.ready)
            return "󰂑";

        if (PowerService.charging)
            return "󰂄";

        const level = PowerService.percentage;

        if (level >= 90)
            return "󰁹";
        if (level >= 70)
            return "󰂀";
        if (level >= 50)
            return "󰁾";
        if (level >= 30)
            return "󰁼";
        if (level >= 15)
            return "󰁺";

        return "󰂎";
    }

    Row {
        anchors.centerIn: parent
        spacing: 5

        Text {
            width: 18
            height: 28

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: root.icon

            font.family: Theme.shellFont
            font.pixelSize: 15

            color: {
                if (PowerService.charging)
                    return Theme.green;

                if (PowerService.percentage <= 15)
                    return Theme.red;

                return Theme.text;
            }
        }

        Text {
            width: 42
            height: 28

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            text: PowerService.ready
                ? Math.round(PowerService.percentage) + "%"
                : "—"

            font.family: Theme.shellFont
            font.pixelSize: 10
            font.weight: Font.DemiBold

            color: Theme.text
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
