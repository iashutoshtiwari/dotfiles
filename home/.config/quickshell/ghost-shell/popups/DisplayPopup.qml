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
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: Theme.popupStandard
    implicitHeight: Math.ceil((content.implicitHeight + 32) / 4) * 4

    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (visible) {
            BrightnessService.refresh();
            KeyboardBacklightService.refresh(false);
        }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

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
                    font.family: Theme.appFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                Text {
                    width: 80
                    horizontalAlignment: Text.AlignRight
                    text: BrightnessService.brightnessPercent + "%"
                    font.family: Theme.appFont
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

            // KEYBOARD BACKLIGHT SECTION
            Column {
                width: parent.width
                spacing: 10
                visible: KeyboardBacklightService.available

                // KEYBOARD BACKLIGHT HEADER
                Row {
                    width: parent.width

                    Row {
                        width: parent.width - 80
                        spacing: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "󰌌"
                            font.family: Theme.shellFont
                            font.pixelSize: 13
                            color: KeyboardBacklightService.brightness > 0 ? Theme.lavender : Theme.overlay1
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "KEYBOARD BACKLIGHT"
                            font.family: Theme.shellFont
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: Theme.text
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        width: 80
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (KeyboardBacklightService.maximum === 2) {
                                if (KeyboardBacklightService.brightness === 0)
                                    return "Off";
                                if (KeyboardBacklightService.brightness === 1)
                                    return "Low";
                                return "High";
                            }
                            return KeyboardBacklightService.brightness + " / " + KeyboardBacklightService.maximum;
                        }
                        font.family: Theme.shellFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: KeyboardBacklightService.brightness > 0 ? Theme.lavender : Theme.subtext0
                    }
                }

                // DISCRETE SLIDER TRACK & STEPS
                Item {
                    id: kbdSlider
                    width: parent.width
                    height: 20

                    readonly property int maxSteps: Math.max(1, KeyboardBacklightService.maximum)
                    readonly property real normalized: KeyboardBacklightService.normalizedBrightness

                    // Track Background
                    Rectangle {
                        id: kbdTrack
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        color: Theme.surface1

                        // Active Fill
                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: parent.width * kbdSlider.normalized
                            color: Theme.accent

                            Behavior on width {
                                enabled: !kbdMouse.pressed
                                NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                            }
                        }

                        // Tick marks for discrete steps
                        Repeater {
                            model: kbdSlider.maxSteps + 1

                            delegate: Rectangle {
                                required property int index
                                width: 2
                                height: 7
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.round((parent.width - width) * (index / kbdSlider.maxSteps))
                                color: index <= KeyboardBacklightService.brightness ? Theme.accent : Theme.surface2
                            }
                        }
                    }

                    // Thumb
                    Rectangle {
                        id: kbdThumb
                        anchors.verticalCenter: kbdTrack.verticalCenter
                        width: 10
                        height: 10
                        radius: 0
                        color: Theme.accent

                        x: Math.max(0, Math.min(kbdTrack.width - width, kbdTrack.width * kbdSlider.normalized - width / 2))

                        Behavior on x {
                            enabled: !kbdMouse.pressed
                            NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        id: kbdMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        function updateLevel() {
                            const ratio = Math.max(0, Math.min(1, mouseX / width));
                            const step = Math.round(ratio * kbdSlider.maxSteps);
                            if (step !== KeyboardBacklightService.brightness) {
                                KeyboardBacklightService.setLevel(step);
                            }
                        }

                        onPressed: updateLevel()
                        onPositionChanged: {
                            if (pressed)
                                updateLevel();
                        }

                        onWheel: wheel => {
                            if (wheel.angleDelta.y > 0)
                                KeyboardBacklightService.increase();
                            else if (wheel.angleDelta.y < 0)
                                KeyboardBacklightService.decrease();
                            wheel.accepted = true;
                        }
                    }
                }

                // LABELS (Off, Low, High for max=2; dynamic for other steps)
                Item {
                    width: parent.width
                    height: 16

                    Repeater {
                        model: KeyboardBacklightService.maximum + 1

                        delegate: Item {
                            required property int index
                            readonly property int totalSteps: KeyboardBacklightService.maximum
                            readonly property string labelText: {
                                if (totalSteps === 2) {
                                    if (index === 0) return "Off";
                                    if (index === 1) return "Low";
                                    return "High";
                                }
                                if (index === 0) return "Off";
                                if (index === totalSteps) return "Max";
                                return index.toString();
                            }

                            width: labelItem.implicitWidth + 8
                            height: parent.height

                            x: {
                                if (index === 0)
                                    return 0;
                                if (index === totalSteps)
                                    return parent.width - width;
                                return Math.round((parent.width - width) * (index / totalSteps));
                            }

                            Text {
                                id: labelItem
                                anchors.centerIn: parent
                                text: parent.labelText
                                font.family: Theme.shellFont
                                font.pixelSize: 10
                                font.weight: KeyboardBacklightService.brightness === parent.index ? Font.DemiBold : Font.Normal
                                color: KeyboardBacklightService.brightness === parent.index ? Theme.lavender : Theme.overlay1
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: KeyboardBacklightService.setLevel(parent.index)
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
