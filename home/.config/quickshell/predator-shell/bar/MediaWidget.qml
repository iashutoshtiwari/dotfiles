import QtQuick

import qs.theme
import qs.services

Item {
    id: root

    visible: MprisService.available
             && MprisService.title.length > 0

    implicitWidth: visible ? 340 : 0
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent

        color: mouse.containsMouse ? Theme.surface0 : Theme.mantle

        border.width: 1
        border.color: Theme.surface0

        radius: Theme.radius

        Row {
            anchors.centerIn: parent

            spacing: 8

            Text {
                text: "󰝚"

                font.family: Theme.appFont
                font.pixelSize: 13

                color: Theme.lavender
            }

            Text {
                width: 245

                text: {
                    if (!MprisService.artist)
                        return MprisService.title;

                    return MprisService.title
                           + "  ·  "
                           + MprisService.artist;
                }

                elide: Text.ElideRight

                font.family: Theme.shellFont
                font.pixelSize: 12
                font.weight: Font.Medium

                color: Theme.text
            }

            Text {
                text: MprisService.playing ? "󰏤" : "󰐊"

                font.family: Theme.shellFont
                font.pixelSize: 12

                color: Theme.subtext1
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: MprisService.toggle()
        }
    }
}
