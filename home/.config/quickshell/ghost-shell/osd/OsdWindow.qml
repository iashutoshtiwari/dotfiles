import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import qs.theme
import qs.services

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ghost-osd"

    exclusiveZone: 0
    color: "transparent"

    anchors {
        bottom: true
    }

    margins.bottom: 72

    implicitWidth: 260
    implicitHeight: 64

    property bool initialized: false
    property bool shown: false

    property string currentIcon: "󰕾"
    property string currentTitle: "Volume"
    property string currentValueText: "50%"
    property int currentLevel: 50
    property bool isMuted: false
    property bool showBar: true
    property bool lowBatteryNotified: false
    property bool criticalBatteryNotified: false

    visible: root.shown || card.opacity > 0

    function showOsd(icon: string, title: string, valueText: string, level: int, muted: bool, hasBar: bool): void {
        if (!initialized)
            return;

        currentIcon = icon;
        currentTitle = title;
        currentValueText = valueText;
        currentLevel = level;
        isMuted = muted;
        showBar = hasBar;

        shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: root.shown = false
    }

    Timer {
        id: startupTimer
        interval: 2000
        running: true
        onTriggered: root.initialized = true
    }

    // AUDIO OUTPUT TRACKING
    Connections {
        target: AudioService

        function onOutputVolumeChanged(): void {
            if (!root.initialized)
                return;

            const pct = Math.round(AudioService.outputVolume * 100);
            let icon = "󰕾";
            if (AudioService.outputMuted)
                icon = "󰖁";
            else if (pct < 1)
                icon = "󰕿";
            else if (pct < 50)
                icon = "󰖀";

            root.showOsd(
                icon,
                "Volume",
                AudioService.outputMuted ? "Muted" : pct + "%",
                pct,
                AudioService.outputMuted,
                true
            );
        }

        function onOutputMutedChanged(): void {
            if (!root.initialized)
                return;

            const pct = Math.round(AudioService.outputVolume * 100);
            root.showOsd(
                AudioService.outputMuted ? "󰖁" : "󰕾",
                "Volume",
                AudioService.outputMuted ? "Muted" : pct + "%",
                pct,
                AudioService.outputMuted,
                true
            );
        }

        function onInputVolumeChanged(): void {
            if (!root.initialized)
                return;

            const pct = Math.round(AudioService.inputVolume * 100);
            root.showOsd(
                AudioService.inputMuted ? "󰍭" : "󰍬",
                "Microphone",
                AudioService.inputMuted ? "Muted" : pct + "%",
                pct,
                AudioService.inputMuted,
                true
            );
        }

        function onInputMutedChanged(): void {
            if (!root.initialized)
                return;

            const pct = Math.round(AudioService.inputVolume * 100);
            root.showOsd(
                AudioService.inputMuted ? "󰍭" : "󰍬",
                "Microphone",
                AudioService.inputMuted ? "Muted" : pct + "%",
                pct,
                AudioService.inputMuted,
                true
            );
        }
    }

    // BRIGHTNESS TRACKING
    Connections {
        target: BrightnessService

        function onBrightnessPercentChanged(): void {
            if (!root.initialized)
                return;

            const pct = BrightnessService.brightnessPercent;
            let icon = "󰃠";
            if (pct < 30)
                icon = "󰃞";
            else if (pct < 70)
                icon = "󰃟";

            root.showOsd(
                icon,
                "Brightness",
                pct + "%",
                pct,
                false,
                true
            );
        }
    }

    // POWER AND BATTERY FEEDBACK
    Connections {
        target: PowerService

        function onOnBatteryChanged(): void {
            if (!root.initialized || !PowerService.ready)
                return;

            const percentage = Math.round(PowerService.percentage);
            root.showOsd(
                PowerService.onBattery ? "󰁹" : "󰂄",
                PowerService.onBattery ? "On Battery" : "Power Connected",
                percentage + "%",
                percentage,
                false,
                true
            );
        }

        function onProfileChanged(): void {
            if (!root.initialized)
                return;

            root.showOsd(
                "󰓅",
                "Power Profile",
                PowerService.profileName,
                0,
                false,
                false
            );
        }

        function onPercentageChanged(): void {
            if (!root.initialized || !PowerService.ready || !PowerService.onBattery)
                return;

            const percentage = Math.round(PowerService.percentage);

            if (percentage > 20) {
                root.lowBatteryNotified = false;
                root.criticalBatteryNotified = false;
                return;
            }

            if (percentage <= 7 && !root.criticalBatteryNotified) {
                root.criticalBatteryNotified = true;
                root.lowBatteryNotified = true;
                Quickshell.execDetached([
                    "notify-send", "-a", "Ghost Shell", "-u", "critical",
                    "Critical Battery", percentage + "% remaining. Connect power now."
                ]);
            } else if (percentage <= 15 && !root.lowBatteryNotified) {
                root.lowBatteryNotified = true;
                Quickshell.execDetached([
                    "notify-send", "-a", "Ghost Shell", "-u", "normal",
                    "Low Battery", percentage + "% remaining."
                ]);
            }
        }
    }

    // KEYBOARD LOCK STATES (HYPRLAND COMPOSITOR QUERY)
    property string pendingLockKey: ""

    Timer {
        id: keyboardStateTimer
        interval: 100
        onTriggered: {
            if (!keyboardStateProcess.running)
                keyboardStateProcess.exec(["hyprctl", "devices", "-j"]);
        }
    }

    Process {
        id: keyboardStateProcess
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            id: keyboardStateOut
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    const data = JSON.parse(keyboardStateOut.text);
                    const kbs = data.keyboards || [];
                    const kb = kbs.find(k => k.main) || kbs[0];
                    if (!kb)
                        return;

                    if (root.pendingLockKey === "numlock") {
                        const isOn = (kb.numLock === true);
                        root.showOsd(
                            "󰎀",
                            "Num Lock",
                            isOn ? "ON" : "OFF",
                            isOn ? 100 : 0,
                            !isOn,
                            false
                        );
                    } else if (root.pendingLockKey === "capslock") {
                        const isOn = (kb.capsLock === true);
                        root.showOsd(
                            "󰬈",
                            "Caps Lock",
                            isOn ? "ON" : "OFF",
                            isOn ? 100 : 0,
                            !isOn,
                            false
                        );
                    }
                } catch (e) {
                    console.error("Failed to parse hyprctl devices JSON:", e);
                }
            }
        }
    }

    // SCROLL LOCK STATE (SOFTWARE TRACKED)
    property bool scrollLockOn: false

    function toggleScrollLock(): void {
        scrollLockOn = !scrollLockOn;
        root.showOsd(
            "󰓡",
            "Scroll Lock",
            scrollLockOn ? "ON" : "OFF",
            scrollLockOn ? 100 : 0,
            !scrollLockOn,
            false
        );
    }

    // AIRPLANE MODE PROCESSES (HARDWARE REFLECTIVE)
    Timer {
        id: airplaneQueryTimer
        interval: 100
        onTriggered: {
            if (!airplaneQueryProcess.running)
                airplaneQueryProcess.exec(["rfkill", "-J", "list", "all"]);
        }
    }

    Process {
        id: airplaneActionProcess
    }

    Process {
        id: airplaneQueryProcess
        command: ["rfkill", "-J", "list", "all"]
        stdout: StdioCollector {
            id: airplaneOut
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    const data = JSON.parse(airplaneOut.text);
                    const devices = data.rfkilldevices || [];
                    const wlanDevices = devices.filter(d => d.type === "wlan" || (d.device && d.device.indexOf("wireless") >= 0));
                    const targetDevices = wlanDevices.length > 0 ? wlanDevices : devices;
                    const anyBlocked = targetDevices.some(d => d.soft === "blocked");
                    root.showOsd(
                        "󰀝",
                        "Airplane Mode",
                        anyBlocked ? "ON" : "OFF",
                        anyBlocked ? 100 : 0,
                        anyBlocked,
                        false
                    );
                } catch (e) {
                    console.error("Failed to parse rfkill JSON:", e);
                }
            }
        }
    }

    function updateAirplaneMode(): void {
        airplaneQueryTimer.restart();
    }

    function toggleAirplaneMode(): void {
        if (!airplaneToggleQueryProcess.running)
            airplaneToggleQueryProcess.exec(["rfkill", "-J", "list", "all"]);
    }

    Process {
        id: airplaneToggleQueryProcess
        command: ["rfkill", "-J", "list", "all"]
        stdout: StdioCollector {
            id: airplaneToggleOut
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    const data = JSON.parse(airplaneToggleOut.text);
                    const devices = data.rfkilldevices || [];
                    const anyUnblocked = devices.some(d => d.soft === "unblocked");
                    if (anyUnblocked) {
                        airplaneActionProcess.exec(["rfkill", "block", "all"]);
                        root.showOsd("󰀝", "Airplane Mode", "ON", 100, true, false);
                    } else {
                        airplaneActionProcess.exec(["rfkill", "unblock", "all"]);
                        root.showOsd("󰀝", "Airplane Mode", "OFF", 0, false, false);
                    }
                } catch (e) {
                    console.error("Failed to parse rfkill JSON:", e);
                }
            }
        }
    }

    // EXTERNAL IPC TRIGGER
    IpcHandler {
        target: "osd"

        function updateCapsLock(): void {
            root.pendingLockKey = "capslock";
            keyboardStateTimer.restart();
        }

        function toggleCapsLock(): void {
            root.pendingLockKey = "capslock";
            keyboardStateTimer.restart();
        }

        function updateNumLock(): void {
            root.pendingLockKey = "numlock";
            keyboardStateTimer.restart();
        }

        function toggleNumLock(): void {
            root.pendingLockKey = "numlock";
            keyboardStateTimer.restart();
        }

        function toggleScrollLock(): void {
            root.toggleScrollLock();
        }

        function updateAirplaneMode(): void {
            root.updateAirplaneMode();
        }

        function toggleAirplaneMode(): void {
            root.toggleAirplaneMode();
        }

        function show(icon: string, title: string, valueText: string, level: string, muted: string): void {
            root.showOsd(
                icon,
                title,
                valueText,
                parseInt(level) || 0,
                muted === "true",
                true
            );
        }
    }

    // OSD CARD DESIGN
    Rectangle {
        id: card
        anchors.fill: parent

        opacity: root.shown ? 1.0 : 0.0
        scale: root.shown || Theme.reducedMotion ? 1.0 : 0.99
        y: root.shown || Theme.reducedMotion ? 0 : 4

        Behavior on opacity {
            NumberAnimation {
                duration: root.shown ? Theme.motionNormal : Theme.motionExit
                easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: root.shown ? Theme.motionNormal : Theme.motionExit
                easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: root.shown ? Theme.motionNormal : Theme.motionExit
                easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
            }
        }

        color: Theme.mantle
        border.width: 1
        border.color: Theme.surface1
        radius: Theme.radius

        Row {
            anchors {
                fill: parent
                margins: 14
            }
            spacing: 12

            Text {
                id: iconDisplay
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.shellFont
                font.pixelSize: 22
                color: root.isMuted ? Theme.red : Theme.lavender
                text: root.currentIcon
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - iconDisplay.width - 12
                spacing: 6

                Row {
                    width: parent.width

                    Text {
                        width: parent.width - valueDisplay.width
                        font.family: Theme.appFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.text
                        text: root.currentTitle
                    }

                    Text {
                        id: valueDisplay
                        font.family: Theme.appFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.isMuted ? Theme.red : Theme.lavender
                        text: root.currentValueText
                    }
                }

                // LEVEL BAR
                Rectangle {
                    width: parent.width
                    height: 4
                    color: Theme.surface1
                    visible: root.showBar

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.currentLevel / 100))
                        height: parent.height
                        color: root.isMuted ? Theme.red : Theme.lavender

                        Behavior on width {
                            NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                        }
                        Behavior on color {
                            ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}
