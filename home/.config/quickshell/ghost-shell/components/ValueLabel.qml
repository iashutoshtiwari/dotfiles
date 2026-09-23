import QtQuick
import QtQuick.Layouts

import qs.theme

RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property string valueFont: Theme.monoFont
    property color valueColor: Theme.lavender
    property color labelColor: Theme.overlay1
    property int valuePixelSize: Theme.fontCaption
    property int labelPixelSize: Theme.fontCaption

    implicitWidth: 260
    implicitHeight: 20

    Text {
        Layout.fillWidth: true
        text: root.label
        font.family: Theme.appFont
        font.pixelSize: root.labelPixelSize
        color: root.labelColor
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: root.value
        font.family: root.valueFont
        font.pixelSize: root.valuePixelSize
        font.weight: Font.Medium
        color: root.valueColor
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }
}
