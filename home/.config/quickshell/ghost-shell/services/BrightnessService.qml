pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool ready: readyVal
    readonly property bool available: availableVal
    readonly property string device: deviceVal
    readonly property int maxBrightness: maxVal
    readonly property int brightness: currentVal
    readonly property int brightnessPercent: percentVal

    property bool readyVal: false
    property bool availableVal: false
    property string deviceVal: ""
    property int maxVal: 1500
    property int currentVal: 900
    property int percentVal: 60

    property int pendingPercent: -1

    function clamp(val: int, minVal: int, maxVal: int): int {
        return Math.max(minVal, Math.min(maxVal, val));
    }

    function refresh(): void {
        if (queryProcess.running)
            return;
        queryProcess.exec(["brightnessctl", "-m"]);
    }

    function setPercent(targetPct: int): void {
        const clamped = clamp(targetPct, 5, 100);
        if (clamped !== percentVal) {
            percentVal = clamped;
        }

        if (setProcess.running) {
            pendingPercent = clamped;
            return;
        }

        pendingPercent = -1;
        setProcess.exec(["brightnessctl", "set", clamped + "%"]);
    }

    function increase(step: int): void {
        const delta = step > 0 ? step : 5;
        if (setProcess.running)
            return;
        setProcess.exec(["brightnessctl", "-e4", "-n2", "set", delta + "%+"]);
    }

    function decrease(step: int): void {
        const delta = step > 0 ? step : 5;
        if (setProcess.running)
            return;
        setProcess.exec(["brightnessctl", "-e4", "-n2", "set", delta + "%-"]);
    }

    Process {
        id: queryProcess

        stdout: StdioCollector {
            id: queryOut
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.availableVal = false;
                root.readyVal = true;
                return;
            }

            const raw = queryOut.text.trim();
            if (!raw)
                return;

            const lines = raw.split("\n");
            const line = lines[lines.length - 1];
            const parts = line.split(",");
            if (parts.length >= 4) {
                root.deviceVal = parts[0];
                root.currentVal = parseInt(parts[2]) || root.currentVal;
                const pct = parseInt(parts[3]) || root.percentVal;
                root.maxVal = parseInt(parts[4]) || root.maxVal;
                root.availableVal = true;
                root.readyVal = true;

                if (pct !== root.percentVal) {
                    root.percentVal = pct;
                }
            }
        }
    }

    Process {
        id: setProcess

        onExited: exitCode => {
            if (root.pendingPercent >= 0) {
                const next = root.pendingPercent;
                root.pendingPercent = -1;
                root.setPercent(next);
            } else {
                root.refresh();
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "brightness"

        function increase(): void {
            root.increase(5);
        }

        function decrease(): void {
            root.decrease(5);
        }

        function set(value: string): void {
            root.setPercent(parseInt(value));
        }

        function refresh(): void {
            root.refresh();
        }
    }

    Component.onCompleted: refresh()
}
