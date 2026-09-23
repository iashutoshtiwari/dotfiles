import QtQuick
import QtQuick.Layouts

import qs.theme

Rectangle {
    id: root

    property var model: []
    property var currentValue
    property int currentIndex: -1
    property color accentColor: Theme.lavender
    property string fontFamily: Theme.appFont
    property int fontPixelSize: Theme.fontCaption
    property bool compact: false

    signal selected(var value, int index)

    implicitWidth: 260
    implicitHeight: compact ? Theme.controlCompact : Theme.controlNormal
    color: Theme.base
    border.width: Theme.surfaceBorder
    border.color: Theme.surface1
    radius: 0

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.model

            Rectangle {
                id: segment
                required property var modelData
                required property int index

                readonly property var itemValue: modelData !== null && modelData.value !== undefined
                    ? modelData.value : modelData
                readonly property string itemLabel: modelData !== null && modelData.label !== undefined
                    ? modelData.label : (modelData !== null ? modelData.toString() : "")
                readonly property bool itemAvailable: modelData !== null && modelData.available !== undefined
                    ? modelData.available : true
                readonly property bool isSelected: root.currentValue !== undefined
                    ? root.currentValue === itemValue
                    : root.currentIndex === index

                Layout.fillWidth: true
                Layout.fillHeight: true

                color: isSelected
                    ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, Theme.highlightOpacity)
                    : (segmentMouse.containsMouse && itemAvailable ? Theme.surface0 : "transparent")
                opacity: itemAvailable ? 1.0 : Theme.disabledOpacity
                radius: 0

                Behavior on color {
                    ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                }

                // Ghost signature active rail (bottom edge)
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: Theme.activeRail
                    color: root.accentColor
                    visible: segment.isSelected
                }

                Text {
                    anchors.centerIn: parent
                    text: segment.itemLabel
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                    font.weight: segment.isSelected ? Font.DemiBold : Font.Normal
                    color: segment.isSelected
                        ? root.accentColor
                        : (segmentMouse.containsMouse ? Theme.text : Theme.subtext1)
                }

                MouseArea {
                    id: segmentMouse
                    anchors.fill: parent
                    enabled: segment.itemAvailable
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        root.currentValue = segment.itemValue;
                        root.currentIndex = segment.index;
                        root.selected(segment.itemValue, segment.index);
                    }
                }
            }
        }
    }
}
