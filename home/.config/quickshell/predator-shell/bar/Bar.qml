import QtQuick
import Quickshell
import Quickshell.Io

import qs.theme
import qs.popups

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: Theme.barMargin
                left: Theme.barMargin
                right: Theme.barMargin
            }

            implicitHeight: Theme.barHeight

            exclusiveZone:
                Theme.barHeight + Theme.barMargin

            color: "transparent"

            readonly property var allPopups: [
                notificationCenter,
                networkPopup,
                bluetoothPopup,
                displayPopup,
                wallpaperPicker,
                audioPopup,
                powerPopup,
                weatherPopup,
                clockPopup,
                powerMenuPopup
            ]

            function togglePopup(targetPopup): void {
                if (!targetPopup)
                    return;
                const wasVisible = targetPopup.visible;
                closeAllPopups();
                if (!wasVisible) {
                    targetPopup.visible = true;
                }
            }

            function closeAllPopups(): void {
                for (let i = 0; i < allPopups.length; i++) {
                    const p = allPopups[i];
                    if (p && p.visible) {
                        p.visible = false;
                    }
                }
            }

            IpcHandler {
                target: "popups"

                function closeAll(): void {
                    root.closeAllPopups();
                }

                function toggle(name: string): void {
                    const map = {
                        "notifications": notificationCenter,
                        "network": networkPopup,
                        "bluetooth": bluetoothPopup,
                        "display": displayPopup,
                        "wallpaper": wallpaperPicker,
                        "audio": audioPopup,
                        "power": powerPopup,
                        "weather": weatherPopup,
                        "clock": clockPopup,
                        "powermenu": powerMenuPopup
                    };
                    const target = map[name];
                    if (target)
                        root.togglePopup(target);
                }
            }

            Rectangle {
                anchors.fill: parent

                color: Theme.base

                border.width: 1
                border.color: Theme.surface0

                radius: Theme.radius

                Workspaces {
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                }

                MediaWidget {
                    anchors.centerIn: parent
                }

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: 4

                    TrayWidget {
                        id: trayWidget
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NotificationButton {
                        id: notificationButton
                        onClicked: root.togglePopup(notificationCenter)
                    }

                    NetworkButton {
                        id: networkButton
                        onClicked: root.togglePopup(networkPopup)
                    }

                    BluetoothButton {
                        id: bluetoothButton
                        onClicked: root.togglePopup(bluetoothPopup)
                    }

                    DisplayButton {
                        id: displayButton
                        onClicked: root.togglePopup(displayPopup)
                    }

                    AudioButton {
                        id: audioButton
                        onClicked: root.togglePopup(audioPopup)
                    }

                    BatteryButton {
                        id: batteryButton
                        onClicked: root.togglePopup(powerPopup)
                    }

                    WeatherButton {
                        id: weatherButton
                        onClicked: root.togglePopup(weatherPopup)
                    }

                    ClockButton {
                        id: clockButton
                        onClicked: root.togglePopup(clockPopup)
                    }

                    PowerButton {
                        id: powerButton
                        onClicked: root.togglePopup(powerMenuPopup)
                    }
                }
            }

            NotificationCenter {
                id: notificationCenter
                anchorItem: notificationButton
            }

            NetworkPopup {
                id: networkPopup
                anchorItem: networkButton
            }

            BluetoothPopup {
                id: bluetoothPopup
                anchorItem: bluetoothButton
            }

            DisplayPopup {
                id: displayPopup
                anchorItem: displayButton
                onOpenWallpaperPicker: root.togglePopup(wallpaperPicker)
            }

            WallpaperPicker {
                id: wallpaperPicker
                anchorItem: displayButton
            }

            AudioPopup {
                id: audioPopup
                anchorItem: audioButton
            }

            PowerPopup {
                id: powerPopup
                anchorItem: batteryButton
            }

            WeatherPopup {
                id: weatherPopup
                anchorItem: weatherButton
            }

            ClockPopup {
                id: clockPopup
                anchorItem: clockButton
            }

            PowerMenuPopup {
                id: powerMenuPopup
                anchorItem: powerButton
            }
        }
    }
}
