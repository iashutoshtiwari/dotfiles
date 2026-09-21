pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available: availableVal
    readonly property bool enabled: enabledVal
    readonly property int temperature: tempVal
    readonly property bool scheduleEnabled: schedVal
    readonly property int scheduleStartHour: 20
    readonly property int scheduleEndHour: 7

    readonly property string statusText: {
        if (!availableVal)
            return "hyprsunset not installed";
        if (!enabledVal)
            return "Off";
        return tempVal + "K (Warm)";
    }

    property bool availableVal: true
    property bool enabledVal: false
    property int tempVal: 4500
    property bool schedVal: false

    function clamp(val: int, minVal: int, maxVal: int): int {
        return Math.max(minVal, Math.min(maxVal, val));
    }

    function toggle(): void {
        setEnabled(!enabledVal);
    }

    function setEnabled(enable: bool): void {
        if (!availableVal)
            return;

        enabledVal = enable;
        if (enable) {
            startProcess.exec(["systemctl", "--user", "start", "hyprsunset.service"]);
        } else {
            applyProcess.exec(["hyprctl", "hyprsunset", "identity"]);
            stopProcess.exec(["systemctl", "--user", "stop", "hyprsunset.service"]);
        }
    }

    function setTemperature(tempK: int): void {
        tempVal = clamp(tempK, 2000, 6500);
        if (enabledVal && availableVal) {
            applyProcess.exec([
                "hyprctl",
                "hyprsunset",
                "temperature",
                tempVal.toString()
            ]);
        }
    }

    function setScheduleEnabled(sched: bool): void {
        schedVal = sched;
        if (schedVal)
            checkSchedule();
    }

    function checkSchedule(): void {
        if (!schedVal || !availableVal)
            return;

        const hour = new Date().getHours();
        const inNight = (hour >= scheduleStartHour || hour < scheduleEndHour);
        if (inNight !== enabledVal)
            setEnabled(inNight);
    }

    Process {
        id: checkAvail
        command: ["which", "hyprsunset"]
        onExited: exitCode => {
            root.availableVal = (exitCode === 0);
        }
    }

    Process {
        id: startProcess
        onExited: exitCode => {
            if (root.enabledVal) {
                applyProcess.exec([
                    "hyprctl",
                    "hyprsunset",
                    "temperature",
                    root.tempVal.toString()
                ]);
            }
        }
    }

    Process {
        id: applyProcess
    }

    Process {
        id: stopProcess
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.checkSchedule()
    }

    IpcHandler {
        target: "nightlight"

        function toggle(): void {
            root.toggle();
        }

        function setTemp(value: string): void {
            root.setTemperature(parseInt(value));
        }

        function enable(): void {
            root.setEnabled(true);
        }

        function disable(): void {
            root.setEnabled(false);
        }
    }

    Component.onCompleted: {
        checkAvail.exec(["which", "hyprsunset"]);
    }
}
