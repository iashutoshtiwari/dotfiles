import QtQuick
import QtQuick.Layouts

import qs.theme

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string actionIcon: ""
    property bool actionEnabled: true

    signal actionClicked()

    implicitHeight: 44

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        Text {
            Layout.preferredWidth: 22
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: root.implicitHeight

            text: root.icon
            font.family: Theme.shellFont
            font.pixelSize: 16
            color: Theme.lavender
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.family: Theme.appFont
                font.pixelSize: Theme.textHeading
                font.weight: Font.DemiBold
                color: Theme.text
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                elide: Text.ElideRight
                font.family: Theme.appFont
                font.pixelSize: Theme.textSmall
                color: Theme.subtext0
            }
        }

        IconButton {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            visible: root.actionIcon.length > 0
            icon: root.actionIcon
            enabled: root.actionEnabled
            onClicked: root.actionClicked()
        }
    }
}
