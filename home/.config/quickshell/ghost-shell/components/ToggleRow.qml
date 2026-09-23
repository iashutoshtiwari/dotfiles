import QtQuick
import QtQuick.Layouts

import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string description: ""
    property bool checked: false
    property color activeColor: Theme.lavender
    property bool isSwitch: true
    property bool hasRail: false
    property bool interactive: true

    signal toggled(bool checked)

    implicitWidth: 260
    implicitHeight: description.length > 0 ? Theme.rowNormal : Theme.rowCompact
    color: toggleMouse.containsMouse && interactive ? Theme.surface0 : "transparent"
    radius: 0
    opacity: enabled ? 1.0 : Theme.disabledOpacity

    Behavior on color {
        ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
    }

    // Ghost signature active rail (left edge)
    Rectangle {
        width: Theme.activeRail
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        color: root.activeColor
        visible: root.hasRail && root.checked
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spacingSm
            rightMargin: Theme.spacingSm
        }
        spacing: Theme.spacingSm

        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconNormal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.checked ? root.activeColor : Theme.subtext0
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                Layout.fillWidth: true
                text: root.label
                font.family: Theme.appFont
                font.pixelSize: Theme.fontBody
                font.weight: root.checked ? Font.Medium : Font.Normal
                color: Theme.text
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.description.length > 0
                text: root.description
                font.family: Theme.appFont
                font.pixelSize: Theme.fontCaption
                color: Theme.subtext0
                elide: Text.ElideRight
            }
        }

        // Toggle Switch visual
        Rectangle {
            visible: root.isSwitch
            Layout.preferredWidth: 46
            Layout.preferredHeight: 22
            Layout.alignment: Qt.AlignVCenter
            color: root.checked ? root.activeColor : Theme.surface1
            radius: 0

            Behavior on color {
                ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: root.checked ? "ON" : "OFF"
                font.family: Theme.monoFont
                font.pixelSize: Theme.fontCaption
                font.weight: Font.Bold
                color: root.checked ? Theme.crust : Theme.subtext0
            }
        }

        // Checkbox visual (when !isSwitch)
        Text {
            visible: !root.isSwitch
            Layout.alignment: Qt.AlignVCenter
            text: root.checked ? "󰄲" : "󰄱"
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconNormal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.checked ? root.activeColor : Theme.overlay0
        }
    }

    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
