import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.theme

Row {
    id: root

    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItem
            required property var modelData

            width: 26
            height: 26
            color: trayMouse.containsMouse ? Theme.surface0 : "transparent"
            radius: Theme.radius

            IconImage {
                id: iconImg
                anchors.centerIn: parent
                width: 16
                height: 16
                source: (trayItem.modelData && trayItem.modelData.icon) ? Quickshell.iconPath(trayItem.modelData.icon) : ""
            }

            Text {
                anchors.centerIn: parent
                visible: iconImg.status !== Image.Ready && iconImg.status !== Image.Loading
                font.family: Theme.shellFont
                font.pixelSize: 11
                font.weight: Font.Bold
                color: Theme.lavender
                text: ((trayItem.modelData && trayItem.modelData.title) || "?").charAt(0).toUpperCase()
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    if (!trayItem.modelData)
                        return;

                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.modelData.hasMenu) {
                            trayItem.modelData.display(root, mouse.x, mouse.y);
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayItem.modelData.secondaryActivate();
                    }
                }

                onWheel: wheel => {
                    if (trayItem.modelData) {
                        trayItem.modelData.scroll(wheel.angleDelta.y, false);
                    }
                }
            }
        }
    }
}
