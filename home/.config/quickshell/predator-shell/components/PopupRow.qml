import QtQuick
import QtQuick.Layouts

import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string description: ""
    property string value: ""
    property bool selected: false
    property bool interactive: true
    property color statusColor: selected ? Theme.lavender : Theme.subtext0

    signal clicked()

    implicitHeight: description.length > 0 ? Theme.rowNormal : Theme.rowCompact
    color: selected ? Qt.rgba(Theme.lavender.r, Theme.lavender.g, Theme.lavender.b, 0.08)
        : mouse.containsMouse && interactive ? Theme.surface0
        : "transparent"
    radius: Theme.radius

    Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }

    Rectangle {
        width: 2
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        color: Theme.lavender
        visible: root.selected
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        spacing: Theme.spacingSm

        Text {
            Layout.preferredWidth: 22
            Layout.preferredHeight: root.implicitHeight
            text: root.icon
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.shellFont
            font.pixelSize: 14
            color: root.selected ? Theme.lavender : Theme.subtext1
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.label
                elide: Text.ElideRight
                font.family: Theme.appFont
                font.pixelSize: Theme.textBody
                font.weight: root.selected ? Font.Medium : Font.Normal
                color: Theme.text
            }

            Text {
                Layout.fillWidth: true
                visible: root.description.length > 0
                text: root.description
                elide: Text.ElideRight
                font.family: Theme.appFont
                font.pixelSize: Theme.textSmall
                color: Theme.subtext0
            }
        }

        Text {
            Layout.minimumWidth: implicitWidth
            Layout.preferredHeight: root.implicitHeight
            text: root.value
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.appFont
            font.pixelSize: Theme.textSmall
            color: root.statusColor
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
