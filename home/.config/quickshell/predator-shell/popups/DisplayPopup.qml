import QtQuick
import Quickshell

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root

    property Item anchorItem

    signal openWallpaperPicker()

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

            // DISPLAY SECTION HEADER
            Row {
                width: parent.width

                Text {
                    width: parent.width - 80
                    text: "DISPLAY"
                    font.family: Theme.shellFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                Text {
                    width: 80
                    horizontalAlignment: Text.AlignRight
                    text: BrightnessService.brightnessPercent + "%"
                    font.family: Theme.shellFont
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: Theme.lavender
                }
            }

            // BRIGHTNESS SLIDER
            VolumeSlider {
                width: parent.width
                value: BrightnessService.brightnessPercent / 100
                onUserChanged: value => {
                    BrightnessService.setPercent(Math.round(value * 100));
                }
            }

            // BRIGHTNESS PRESETS
            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [25, 50, 75, 100]

                    delegate: Rectangle {
                        required property int modelData

                        width: (content.width - 24) / 4
                        height: 24

                        color: BrightnessService.brightnessPercent === modelData
                            ? Theme.surface1
                            : Theme.surface0

                        border.width: 1
                        border.color: BrightnessService.brightnessPercent === modelData
                            ? Theme.lavender
                            : Theme.surface0

                        radius: Theme.radius

                        Text {
                            anchors.centerIn: parent
                            text: modelData + "%"
                            font.family: Theme.shellFont
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: BrightnessService.brightnessPercent === modelData
                                ? Theme.lavender
                                : Theme.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BrightnessService.setPercent(modelData)
                        }
                    }
                }
            }

            // SEPARATOR
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            // NIGHT LIGHT SECTION HEADER
            Row {
                width: parent.width

                Column {
                    width: parent.width - 70
                    spacing: 2

                    Text {
                        text: "NIGHT LIGHT"
                        font.family: Theme.shellFont
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: NightLightService.statusText
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.subtext0
                    }
                }

                // TOGGLE SWITCH
                Rectangle {
                    width: 48
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: NightLightService.enabled ? Theme.peach : Theme.surface1
                    radius: Theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: NightLightService.enabled ? "ON" : "OFF"
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: NightLightService.enabled ? Theme.crust : Theme.subtext0
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NightLightService.toggle()
                    }
                }
            }

            // TEMPERATURE SLIDER
            Column {
                width: parent.width
                spacing: 8
                visible: NightLightService.available

                Row {
                    width: parent.width

                    Text {
                        width: parent.width - 80
                        text: "Color Temperature"
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.overlay1
                    }

                    Text {
                        width: 80
                        horizontalAlignment: Text.AlignRight
                        text: NightLightService.temperature + "K"
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.peach
                    }
                }

                VolumeSlider {
                    width: parent.width
                    // Map 2000K..6500K -> 0.0..1.0
                    value: (NightLightService.temperature - 2000) / 4500
                    onUserChanged: value => {
                        NightLightService.setTemperature(Math.round(2000 + value * 4500));
                    }
                }

                // TEMPERATURE PRESETS
                Row {
                    width: parent.width
                    spacing: 6

                    readonly property var presets: [
                        { name: "Cool", temp: 6000 },
                        { name: "Warm", temp: 4500 },
                        { name: "Cozy", temp: 3500 },
                        { name: "Candle", temp: 2500 }
                    ]

                    Repeater {
                        model: parent.presets

                        delegate: Rectangle {
                            required property var modelData

                            width: (content.width - 18) / 4
                            height: 22

                            color: NightLightService.temperature === modelData.temp
                                ? Theme.surface1
                                : Theme.surface0

                            border.width: 1
                            border.color: NightLightService.temperature === modelData.temp
                                ? Theme.peach
                                : Theme.surface0

                            radius: Theme.radius

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                font.family: Theme.shellFont
                                font.pixelSize: 9
                                font.weight: Font.Medium
                                color: NightLightService.temperature === modelData.temp
                                    ? Theme.peach
                                    : Theme.text
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NightLightService.setTemperature(modelData.temp);
                                    if (!NightLightService.enabled)
                                        NightLightService.setEnabled(true);
                                }
                            }
                        }
                    }
                }
            }

            // SCHEDULE TOGGLE
            Rectangle {
                width: parent.width
                height: 32
                color: Theme.surface0
                radius: Theme.radius
                visible: NightLightService.available

                Row {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10
                    }

                    Text {
                        width: parent.width - 40
                        text: "Schedule: 20:00 – 07:00"
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.text
                    }

                    Text {
                        width: 40
                        horizontalAlignment: Text.AlignRight
                        text: NightLightService.scheduleEnabled ? "󰄲" : "󰄱"
                        font.family: Theme.shellFont
                        font.pixelSize: 14
                        color: NightLightService.scheduleEnabled ? Theme.lavender : Theme.overlay0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NightLightService.setScheduleEnabled(!NightLightService.scheduleEnabled)
                }
            }

            // SEPARATOR
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            // WALLPAPER SECTION
            Row {
                width: parent.width

                Column {
                    width: parent.width - 110
                    spacing: 2

                    Text {
                        text: "WALLPAPER"
                        font.family: Theme.shellFont
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: WallpaperService.currentWallpaperName || "Default"
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.subtext0
                        elide: Text.ElideMiddle
                        width: parent.width
                    }
                }

                // CHANGE WALLPAPER BUTTON
                Rectangle {
                    width: 100
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    color: changeWpMouse.containsMouse ? Theme.surface1 : Theme.surface0
                    border.width: 1
                    border.color: Theme.lavender
                    radius: Theme.radius

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "󰸉"
                            font.family: Theme.shellFont
                            font.pixelSize: 11
                            color: Theme.lavender
                        }

                        Text {
                            text: "Gallery"
                            font.family: Theme.shellFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }

                    MouseArea {
                        id: changeWpMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.openWallpaperPicker();
                            root.visible = false;
                        }
                    }
                }
            }
        }
    }
}
