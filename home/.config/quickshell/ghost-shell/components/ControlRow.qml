import QtQuick
import QtQuick.Layouts

import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property color iconColor: Theme.lavender
    property string title: ""
    property string description: ""
    property string shortcut: ""
    property bool danger: false
    property bool active: false
    property bool hasRail: active
    property color railColor: danger ? Theme.red : iconColor

    signal clicked()

    implicitWidth: 260
    implicitHeight: 42

    color: active && danger
        ? Theme.red
        : (rowMouse.pressed
            ? Theme.surface1
            : (rowMouse.containsMouse
                ? Theme.surface0
                : (active ? Qt.rgba(Theme.lavender.r, Theme.lavender.g, Theme.lavender.b, 0.12) : Theme.mantle)))

    border.width: Theme.surfaceBorder
    border.color: active && danger
        ? Theme.red
        : (rowMouse.containsMouse
            ? (danger ? Theme.red : iconColor)
            : (active ? iconColor : Theme.surface0))

    radius: 0

    Behavior on color {
        ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
    }
    Behavior on border.color {
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
        color: root.railColor
        visible: root.hasRail && !root.active
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spacingMd
            rightMargin: Theme.spacingMd
        }
        spacing: Theme.spacingMd

        Text {
            visible: root.icon.length > 0
            Layout.alignment: Qt.AlignVCenter
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconNormal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.active && root.danger
                ? Theme.crust
                : (root.danger && rowMouse.containsMouse ? Theme.red : root.iconColor)
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.title
                font.family: Theme.appFont
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                color: root.active && root.danger ? Theme.crust : Theme.text
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.description.length > 0
                text: root.description
                font.family: Theme.appFont
                font.pixelSize: Theme.fontCaption
                color: root.active && root.danger ? Theme.crust : Theme.subtext0
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.shortcut.length > 0
            Layout.alignment: Qt.AlignVCenter
            text: root.shortcut
            font.family: Theme.monoFont
            font.pixelSize: Theme.fontCaption
            color: root.active && root.danger ? Theme.crust : Theme.overlay1
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
