import QtQuick
import QtQuick.Layouts

import qs.theme

RowLayout {
    id: root

    property string status: "idle" // "idle", "active", "success", "warning", "error", "scanning"
    property string text: ""
    property color color: {
        switch (status) {
            case "active": return Theme.lavender;
            case "success": return Theme.green;
            case "warning": return Theme.peach;
            case "error": return Theme.red;
            case "scanning": return Theme.sapphire;
            default: return Theme.overlay1;
        }
    }

    spacing: Theme.spacingXs

    Rectangle {
        id: dot
        width: 8
        height: 8
        radius: 4
        color: root.color
        Layout.alignment: Qt.AlignVCenter

        SequentialAnimation on opacity {
            running: root.status === "scanning"
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
        }
    }

    Text {
        visible: root.text.length > 0
        text: root.text
        font.family: Theme.appFont
        font.pixelSize: Theme.fontCaption
        color: root.color
        Layout.alignment: Qt.AlignVCenter
    }
}
