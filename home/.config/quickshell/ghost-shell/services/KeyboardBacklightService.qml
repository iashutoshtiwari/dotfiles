pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool ready: readyVal
    readonly property bool available: availableVal
    readonly property string device: deviceVal
    readonly property int brightness: currentVal
    readonly property int maximum: maxVal
    readonly property real normalizedBrightness: maxVal > 0 ? (currentVal / maxVal) : 0.0

    property bool readyVal: false
    property bool availableVal: false
    property string deviceVal: ""
    property int maxVal: 2
    property int currentVal: 0

    property int pendingLevel: -1

    function clamp(val: int, minVal: int, maxVal: int): int {
        return Math.max(minVal, Math.min(maxVal, val));
    }

    function refresh(forceDetect: bool): void {
        const needsDetect = forceDetect || !deviceVal;

        if (needsDetect) {
            if (!detectProcess.running) {
                detectProcess.exec(["brightnessctl", "-m", "--list"]);
            }
            return;
        }

        if (!root.deviceVal)
            return;

        if (queryProcess.running)
            return;

        queryProcess.exec(["brightnessctl", "-m", "-d", root.deviceVal]);
    }

    function setLevel(targetLevel: int): void {
        if (!availableVal || !deviceVal || maxVal <= 0)
            return;

        const clamped = clamp(targetLevel, 0, maxVal);
        if (clamped !== currentVal) {
            currentVal = clamped;
        }

        if (setProcess.running) {
            pendingLevel = clamped;
            return;
        }

        pendingLevel = -1;
        setProcess.exec(["brightnessctl", "-d", deviceVal, "set", clamped.toString()]);
    }

    function increase(): void {
        if (!availableVal)
            return;
        setLevel(currentVal + 1);
    }

    function decrease(): void {
        if (!availableVal)
            return;
        setLevel(currentVal - 1);
    }

    // Conservative detection of keyboard backlight device
    Process {
        id: detectProcess

        stdout: StdioCollector {
            id: detectOut
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.availableVal = false;
                root.readyVal = true;
                return;
            }

            const raw = detectOut.text.trim();
            if (!raw) {
                root.availableVal = false;
                root.readyVal = true;
                return;
            }

            const lines = raw.split("\n");
            let foundDevice = "";
            let foundCurrent = 0;
            let foundMax = 0;

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line)
                    continue;

                const parts = line.split(",");
                if (parts.length >= 5) {
                    const devName = parts[0].toLowerCase();
                    const devClass = parts[1].toLowerCase();

                    // Must be leds class (or vendor backlight class with explicit keyboard in name)
                    if (devClass !== "leds" && devClass !== "backlight")
                        continue;

                    // Reject indicator / non-backlight LEDs
                    const isFalsePositive = devName.includes("capslock") ||
                                            devName.includes("numlock") ||
                                            devName.includes("scrolllock") ||
                                            devName.includes("micmute") ||
                                            devName.includes("mute") ||
                                            devName.includes("power") ||
                                            devName.includes("charging") ||
                                            devName.includes("standby") ||
                                            devName.includes("lid") ||
                                            devName.includes("thinkvantage") ||
                                            devName.includes("lan");

                    if (isFalsePositive)
                        continue;

                    const isKbdBacklight = devName.includes("kbd_backlight") ||
                                           devName.includes("kbd-backlight") ||
                                           (devName.includes("kbd") && devName.includes("backlight")) ||
                                           devName.includes("keyboard_backlight") ||
                                           devName.includes("keyboard-backlight");

                    if (isKbdBacklight) {
                        const maxBrightness = parseInt(parts[4]) || 0;
                        if (maxBrightness > 0) {
                            foundDevice = parts[0];
                            foundCurrent = parseInt(parts[2]) || 0;
                            foundMax = maxBrightness;
                            break;
                        }
                    }
                }
            }

            if (foundDevice) {
                root.deviceVal = foundDevice;
                root.maxVal = foundMax;
                root.currentVal = foundCurrent;
                root.availableVal = true;
                root.readyVal = true;
            } else {
                root.deviceVal = "";
                root.availableVal = false;
                root.readyVal = true;
            }
        }
    }

    // Direct status query of detected device
    Process {
        id: queryProcess

        stdout: StdioCollector {
            id: queryOut
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                // Device query failed (e.g. unplugged/removed); attempt rediscovery
                root.refresh(true);
                return;
            }

            const raw = queryOut.text.trim();
            if (!raw)
                return;

            const lines = raw.split("\n");
            const line = lines[lines.length - 1];
            const parts = line.split(",");
            if (parts.length >= 5) {
                // Ensure the reported device is the expected one
                if (parts[0] !== root.deviceVal)
                    return;

                const cur = parseInt(parts[2]);
                const max = parseInt(parts[4]);
                if (!isNaN(cur) && cur !== root.currentVal) {
                    root.currentVal = cur;
                }
                if (!isNaN(max) && max !== root.maxVal) {
                    root.maxVal = max;
                }
                root.availableVal = true;
                root.readyVal = true;
            }
        }
    }

    // Asynchronous brightnessctl execution
    Process {
        id: setProcess

        onExited: exitCode => {
            if (root.pendingLevel >= 0) {
                const next = root.pendingLevel;
                root.pendingLevel = -1;
                root.setLevel(next);
            } else {
                root.refresh(false);
            }
        }
    }

    // Fast event-driven sysfs watcher for instant hardware synchronization (Fn+Space, external brightnessctl)
    Process {
        id: watcherProcess

        running: root.availableVal && root.deviceVal !== ""

        command: [
            "python3", "-u", "-c",
            "import os, select, sys, time\n" +
            "dev = sys.argv[1]\n" +
            "bp = f'/sys/class/leds/{dev}/brightness'\n" +
            "hwp = f'/sys/class/leds/{dev}/brightness_hw_changed'\n" +
            "poller = select.poll()\n" +
            "hw_fd = -1\n" +
            "if os.path.exists(hwp):\n" +
            "    try:\n" +
            "        hw_fd = os.open(hwp, os.O_RDONLY)\n" +
            "        poller.register(hw_fd, select.POLLPRI | select.POLLERR)\n" +
            "    except Exception:\n" +
            "        hw_fd = -1\n" +
            "def read_b():\n" +
            "    try:\n" +
            "        with open(bp, 'r') as f:\n" +
            "            return int(f.read().strip())\n" +
            "    except Exception:\n" +
            "        return None\n" +
            "last = read_b()\n" +
            "while True:\n" +
            "    if hw_fd != -1:\n" +
            "        ev = poller.poll(100)\n" +
            "        if ev:\n" +
            "            os.lseek(hw_fd, 0, os.SEEK_SET)\n" +
            "            try: os.read(hw_fd, 64)\n" +
            "            except Exception: pass\n" +
            "    else:\n" +
            "        time.sleep(0.1)\n" +
            "    cur = read_b()\n" +
            "    if cur is not None and cur != last:\n" +
            "        last = cur\n" +
            "        print(cur, flush=True)\n",
            root.deviceVal
        ]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const val = parseInt(data.trim());
                if (!isNaN(val) && val !== root.currentVal) {
                    root.currentVal = val;
                }
            }
        }
    }

    // Safety fallback synchronization timer
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh(false)
    }

    IpcHandler {
        target: "keyboardBacklight"

        function increase(): void {
            root.increase();
        }

        function decrease(): void {
            root.decrease();
        }

        function set(value: string): void {
            root.setLevel(parseInt(value));
        }

        function refresh(): void {
            root.refresh(false);
        }
    }

    Component.onCompleted: refresh(true)
}
