import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root
    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: Theme.popupStandard
    implicitHeight: Math.ceil((content.implicitHeight + Theme.popupPadding * 2) / 4) * 4
    color: "transparent"
    grabFocus: true

    function present(): void {
        visible = true;
        Qt.callLater(() => surface.presented = true);
    }

    function dismiss(): void { surface.presented = false; }

    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => surface.presented = true);
        else
            surface.presented = false;
    }

    PopupSurface {
        id: surface
        anchors.fill: parent
        onExitFinished: root.visible = false

        ColumnLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.popupPadding }
            spacing: Theme.spacingMd

            PopupHeader {
                Layout.fillWidth: true
                icon: AudioService.outputMuted ? "󰖁" : "󰕾"
                title: "Audio"
                subtitle: AudioService.ready ? AudioService.outputName : "Audio service unavailable"
                actionIcon: AudioService.outputMuted ? "󰖁" : "󰖀"
                actionEnabled: AudioService.ready
                onActionClicked: AudioService.toggleOutputMute()
            }

            Divider { Layout.fillWidth: true }
            SectionLabel { text: "Output" }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Text {
                        text: AudioService.outputMuted ? "󰖁" : "󰕾"
                        font.family: Theme.iconFont
                        font.pixelSize: Theme.iconNormal
                        color: AudioService.outputMuted ? Theme.red : Theme.lavender
                    }
                    Text {
                        Layout.fillWidth: true
                        text: AudioService.outputName
                        elide: Text.ElideRight
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.Medium
                        color: Theme.text
                    }
                    Text {
                        Layout.preferredWidth: 42
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(AudioService.outputVolume * 100) + "%"
                        font.family: Theme.monoFont
                        font.pixelSize: Theme.fontValue
                        font.weight: Font.Medium
                        color: AudioService.outputMuted ? Theme.overlay0 : Theme.lavender
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm
                    IconButton {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        icon: AudioService.outputMuted ? "󰖁" : "󰕾"
                        active: AudioService.outputMuted
                        foreground: AudioService.outputMuted ? Theme.red : Theme.subtext1
                        onClicked: AudioService.toggleOutputMute()
                    }
                    VolumeSlider {
                        Layout.fillWidth: true
                        value: AudioService.outputVolume
                        enabled: AudioService.ready
                        onUserChanged: value => AudioService.setOutputVolume(value)
                    }
                }
            }

            SectionLabel { text: "Output device" }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Repeater {
                    model: AudioService.outputDevices
                    PopupRow {
                        required property var modelData
                        Layout.fillWidth: true
                        icon: "󰓃"
                        label: modelData.description || modelData.nickname || modelData.name
                        value: modelData === AudioService.sink ? "Active" : ""
                        selected: modelData === AudioService.sink
                        onClicked: AudioService.selectOutput(modelData)
                    }
                }
            }

            Divider { Layout.fillWidth: true }
            SectionLabel { text: "Input" }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm
                    Text {
                        text: AudioService.inputMuted ? "󰍭" : "󰍬"
                        font.family: Theme.iconFont
                        font.pixelSize: Theme.iconNormal
                        color: AudioService.inputMuted ? Theme.red : Theme.sapphire
                    }
                    Text {
                        Layout.fillWidth: true
                        text: AudioService.inputName
                        elide: Text.ElideRight
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.Medium
                        color: Theme.text
                    }
                    Text {
                        Layout.preferredWidth: 42
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(AudioService.inputVolume * 100) + "%"
                        font.family: Theme.monoFont
                        font.pixelSize: Theme.fontValue
                        font.weight: Font.Medium
                        color: AudioService.inputMuted ? Theme.overlay0 : Theme.sapphire
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm
                    IconButton {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        icon: AudioService.inputMuted ? "󰍭" : "󰍬"
                        active: AudioService.inputMuted
                        foreground: AudioService.inputMuted ? Theme.red : Theme.subtext1
                        onClicked: AudioService.toggleInputMute()
                    }
                    VolumeSlider {
                        Layout.fillWidth: true
                        value: AudioService.inputVolume
                        enabled: AudioService.ready
                        onUserChanged: value => AudioService.setInputVolume(value)
                    }
                }
            }

            SectionLabel { text: "Input device" }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Repeater {
                    model: AudioService.inputDevices
                    PopupRow {
                        required property var modelData
                        Layout.fillWidth: true
                        icon: "󰍬"
                        label: modelData.description || modelData.nickname || modelData.name
                        value: modelData === AudioService.source ? "Active" : ""
                        selected: modelData === AudioService.source
                        onClicked: AudioService.selectInput(modelData)
                    }
                }
            }
        }
    }
}
