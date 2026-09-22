import QtQuick
import QtQuick.Layouts

import qs.theme
import qs.services
import qs.components

Item {
    id: root

    property bool active: false
    signal clicked()

    visible: MprisService.available && MprisService.title.length > 0
    implicitWidth: visible ? 340 : 0
    implicitHeight: 28

    BarButtonBackground {
        anchors.fill: parent
        active: root.active
        hovered: mouse.containsMouse
        pressed: mouse.pressed
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingSm
        anchors.rightMargin: Theme.spacingSm
        spacing: Theme.spacingSm

        Rectangle {
            readonly property bool wideArtwork: artwork.status === Image.Ready
                && artwork.sourceSize.height > 0
                && artwork.sourceSize.width / artwork.sourceSize.height >= 1.35

            Layout.preferredWidth: wideArtwork ? 32 : 20
            Layout.preferredHeight: 20
            color: Theme.surface0
            clip: true

            Image {
                id: artwork
                anchors.fill: parent
                source: MprisService.artwork
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !artwork.visible
                text: "󰝚"
                font.family: Theme.shellFont
                font.pixelSize: 12
                color: Theme.lavender
            }
        }

        Text {
            Layout.maximumWidth: 175
            text: MprisService.title
            elide: Text.ElideRight
            font.family: Theme.appFont
            font.pixelSize: Theme.textBody
            font.weight: Font.DemiBold
            color: MprisService.playing ? Theme.text : Theme.subtext1
        }

        Text {
            Layout.fillWidth: true
            text: MprisService.artist.length > 0 ? "—  " + MprisService.artist : ""
            elide: Text.ElideRight
            font.family: Theme.appFont
            font.pixelSize: Theme.textSmall
            color: MprisService.playing ? Theme.lavender : Theme.overlay1
        }

        Text {
            id: playbackStateIcon
            text: MprisService.playing ? "󰏤" : "󰐊"
            font.family: Theme.shellFont
            font.pixelSize: 12
            color: MprisService.playing ? Theme.lavender : Theme.overlay1
            scale: MprisService.playing || Theme.reducedMotion ? 1 : 0.94

            Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
        }
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
