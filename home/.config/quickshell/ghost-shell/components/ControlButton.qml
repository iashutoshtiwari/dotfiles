import QtQuick
import QtQuick.Layouts

import qs.theme

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property color accentColor: Theme.lavender
    property bool active: false
    property bool danger: false
    property bool primary: false
    property bool compact: false
    property bool hasRail: false

    signal clicked()

    implicitHeight: compact ? Theme.controlCompact : Theme.controlNormal
    implicitWidth: contentRow.implicitWidth + (compact ? Theme.spacingMd : Theme.spacingLg)

    color: btnMouse.pressed
        ? (danger ? Theme.red : Theme.surface2)
        : (btnMouse.containsMouse
            ? (danger ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.18) : Theme.surface1)
            : (primary
                ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, Theme.highlightOpacity)
                : (active ? Theme.surface1 : Theme.surface0)))

    border.width: Theme.surfaceBorder
    border.color: danger
        ? Theme.red
        : (btnMouse.containsMouse || active || primary ? root.accentColor : Theme.surface1)

    radius: 0
    opacity: enabled ? 1.0 : Theme.disabledOpacity
    scale: btnMouse.pressed && !Theme.reducedMotion ? 0.98 : 1.0

    Behavior on color {
        ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.motionMicro; easing.type: Easing.OutCubic }
    }

    // Ghost signature active rail (left edge)
    Rectangle {
        width: Theme.activeRail
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        color: danger ? Theme.red : root.accentColor
        visible: root.hasRail && (root.active || root.primary)
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spacingXs

        Text {
            visible: root.icon.length > 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: root.compact ? Theme.iconSmall : Theme.iconNormal
            color: root.danger
                ? (btnMouse.pressed ? Theme.crust : Theme.red)
                : (root.primary || root.active ? root.accentColor : (btnMouse.containsMouse ? Theme.text : Theme.lavender))
        }

        Text {
            visible: root.text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.family: Theme.appFont
            font.pixelSize: root.compact ? Theme.fontCaption : Theme.fontBody
            font.weight: root.primary ? Font.DemiBold : Font.Medium
            color: root.danger
                ? (btnMouse.pressed ? Theme.crust : Theme.red)
                : (root.primary || root.active ? root.accentColor : Theme.text)
        }
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
