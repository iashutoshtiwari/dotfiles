import QtQuick
import Quickshell.Hyprland

import qs.theme

Rectangle {
    id: root

    readonly property string label:
        currentSubmap === "resize" ? "RESIZE" : currentSubmap.toUpperCase()

    property string currentSubmap: ""

    visible: currentSubmap.length > 0 && currentSubmap !== "reset"
    implicitWidth: visible ? labelText.implicitWidth + Theme.spacingMd : 0
    implicitHeight: 20

    color: Theme.surface0
    border.width: Theme.borderWidth
    border.color: Theme.accent
    radius: Theme.radius

    Text {
        id: labelText

        anchors.centerIn: parent

        text: root.label
        color: Theme.accent
        font.family: Theme.monoFont
        font.pixelSize: 9
        font.weight: Font.DemiBold
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name !== "submap")
                return;

            root.currentSubmap = event.data === "reset" ? "" : event.data;
        }
    }
}
