import QtQuick
import QtQuick.Layouts

import qs.theme

ColumnLayout {
    id: root

    property string icon: "󰋼"
    property string message: "Nothing here"

    spacing: Theme.spacingSm

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.icon
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconLarge
        color: Theme.overlay0
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.message
        font.family: Theme.appFont
        font.pixelSize: Theme.fontBody
        color: Theme.subtext0
    }
}
