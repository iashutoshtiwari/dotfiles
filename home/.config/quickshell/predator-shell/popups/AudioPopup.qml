import QtQuick
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
    anchor.margins.top: 8

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 32

    color: "transparent"

    grabFocus: true

    Rectangle {
        anchors.fill: parent

        color: Theme.base

        border.width: 1
        border.color: Theme.surface0

        radius: Theme.radius

        Column {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }

            spacing: 14

            Text {
                text: "Audio"

                font.family: Theme.shellFont
                font.pixelSize: 15
                font.weight: Font.DemiBold

                color: Theme.text
            }

            // Output
            Column {
                width: parent.width
                spacing: 7

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width - 68

                        text: AudioService.outputName
                        elide: Text.ElideRight

                        font.family: Theme.shellFont
                        font.pixelSize: 12

                        color: Theme.subtext1
                    }

                    Text {
                        width: 60

                        horizontalAlignment: Text.AlignRight

                        text:
                            Math.round(
                                AudioService.outputVolume * 100
                            ) + "%"

                        font.family: Theme.shellFont
                        font.pixelSize: 11

                        color: Theme.overlay1
                    }
                }

                Row {
                    spacing: 10

                    Text {
                        width: 22

                        text: AudioService.outputMuted
                            ? "󰖁"
                            : "󰕾"

                        font.family: Theme.shellFont
                        font.pixelSize: 15

                        color: AudioService.outputMuted
                            ? Theme.red
                            : Theme.text

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                AudioService.toggleOutputMute()
                        }
                    }

                    VolumeSlider {
                        width: 290

                        value: AudioService.outputVolume

                        onUserChanged: value =>
                            AudioService.setOutputVolume(value)
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            // Microphone
            Column {
                width: parent.width
                spacing: 7

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width - 68

                        text: AudioService.inputName
                        elide: Text.ElideRight

                        font.family: Theme.shellFont
                        font.pixelSize: 12

                        color: Theme.subtext1
                    }

                    Text {
                        width: 60

                        horizontalAlignment: Text.AlignRight

                        text:
                            Math.round(
                                AudioService.inputVolume * 100
                            ) + "%"

                        font.family: Theme.shellFont
                        font.pixelSize: 11

                        color: Theme.overlay1
                    }
                }

                Row {
                    spacing: 10

                    Text {
                        width: 22

                        text: AudioService.inputMuted
                            ? "󰍭"
                            : "󰍬"

                        font.family: Theme.shellFont
                        font.pixelSize: 15

                        color: AudioService.inputMuted
                            ? Theme.red
                            : Theme.text

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                AudioService.toggleInputMute()
                        }
                    }

                    VolumeSlider {
                        width: 290

                        value: AudioService.inputVolume

                        onUserChanged: value =>
                            AudioService.setInputVolume(value)
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            Text {
                text: "Output devices"

                font.family: Theme.shellFont
                font.pixelSize: 11
                font.weight: Font.DemiBold

                color: Theme.overlay1
            }

            Repeater {
                model: AudioService.outputDevices

                delegate: Rectangle {
                    required property var modelData

                    width: content.width
                    height: 30

                    color:
                        modelData === AudioService.sink
                        ? Theme.surface0
                        : "transparent"

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                        text:
                            modelData.description
                            || modelData.nickname
                            || modelData.name

                        elide: Text.ElideRight

                        font.family: Theme.shellFont
                        font.pixelSize: 11

                        color:
                            modelData === AudioService.sink
                            ? Theme.lavender
                            : Theme.subtext1
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            AudioService.selectOutput(
                                parent.modelData
                            )
                    }
                }
            }

            Text {
                text: "Input devices"

                font.family: Theme.shellFont
                font.pixelSize: 11
                font.weight: Font.DemiBold

                color: Theme.overlay1
            }

            Repeater {
                model: AudioService.inputDevices

                delegate: Rectangle {
                    required property var modelData

                    width: content.width
                    height: 30

                    color:
                        modelData === AudioService.source
                        ? Theme.surface0
                        : "transparent"

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                        text:
                            modelData.description
                            || modelData.nickname
                            || modelData.name

                        elide: Text.ElideRight

                        font.family: Theme.shellFont
                        font.pixelSize: 11

                        color:
                            modelData === AudioService.source
                            ? Theme.lavender
                            : Theme.subtext1
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            AudioService.selectInput(
                                parent.modelData
                            )
                    }
                }
            }
        }
    }
}
