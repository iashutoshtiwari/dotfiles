import QtQuick

import qs.theme
import qs.services
import qs.components

Item {
    id: root

    property bool active: false
    signal clicked()

    visible: MprisService.available && MprisService.title.length > 0
    implicitWidth: visible ? 28 : 0
    implicitHeight: 28

    BarButtonBackground {
        anchors.fill: parent
        active: root.active
        hovered: mouse.containsMouse
        pressed: mouse.pressed
    }

    Text {
        anchors.centerIn: parent
        text: MprisService.playing ? "󰝚" : "󰝛"
        font.family: Theme.shellFont
        font.pixelSize: 13
        color: root.active ? Theme.text : Theme.lavender

        Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                MprisService.toggle();
            else
                root.clicked();
        }
    }
}
