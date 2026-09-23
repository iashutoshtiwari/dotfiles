import QtQuick
import QtQuick.Layouts

import qs.theme

Item {
    id: root

    property string icon: ""
    property color iconColor: Theme.lavender
    property string title: ""
    property string subtitle: ""
    property string value: ""
    property string valueFont: Theme.monoFont
    property color valueColor: Theme.lavender
    property bool uppercase: true

    default property alias trailingSlot: trailingRow.data

    implicitWidth: 260
    implicitHeight: Math.max(subtitle.length > 0 ? 32 : 22, trailingRow.implicitHeight)

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacingSm

        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconNormal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.iconColor
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                Layout.fillWidth: true
                text: root.title
                font.family: Theme.appFont
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                font.capitalization: root.uppercase ? Font.AllUppercase : Font.MixedCase
                font.letterSpacing: root.uppercase ? 0.6 : 0
                color: Theme.text
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                font.family: Theme.appFont
                font.pixelSize: Theme.fontCaption
                color: Theme.subtext0
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.value.length > 0 && trailingRow.children.length === 0
            text: root.value
            font.family: root.valueFont
            font.pixelSize: Theme.fontValue
            font.weight: Font.DemiBold
            color: root.valueColor
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        Row {
            id: trailingRow
            spacing: Theme.spacingXs
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
