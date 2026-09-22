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
                mediaPopup,
                powerMenuPopup
            ]

            function togglePopup(targetPopup): void {
                if (!targetPopup)
                    return;
                const wasVisible = targetPopup.visible;
                // Switching popups is immediate so two layer surfaces never overlap.
                // A same-button dismissal may use the popup's short exit motion.
                for (let i = 0; i < allPopups.length; i++) {
                    const popup = allPopups[i];
                    if (popup && popup !== targetPopup && popup.visible)
                        popup.visible = false;
                }
                if (wasVisible && targetPopup.dismiss)
                    targetPopup.dismiss();
                else if (wasVisible)
                    targetPopup.visible = false;
                else if (targetPopup.present)
                    targetPopup.present();
                else
                    targetPopup.visible = true;
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
                        "media": mediaPopup,
                        "powermenu": powerMenuPopup
                    };
                    const target = map[name];
                    if (target)
                        root.togglePopup(target);
                }
            }

            Rectangle {
                anchors.fill: parent

                // Slight translucency softens the floating bar without making
                // content behind it visually distracting.
                color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.96)

                border.width: 1
                border.color: Theme.surface0

                radius: Theme.radius

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: Theme.spacingSm

                    Workspaces {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ModeIndicator {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ── Center: Media + Weather + Clock ──────────────────
                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    MediaWidget {
                        id: mediaWidget
                        anchors.verticalCenter: parent.verticalCenter
                        active: mediaPopup.visible
                        onClicked: root.togglePopup(mediaPopup)
                    }

                    WeatherButton {
                        id: weatherButton
                        anchors.verticalCenter: parent.verticalCenter
                        active: weatherPopup.visible
                        onClicked: root.togglePopup(weatherPopup)
                    }

                    ClockButton {
                        id: clockButton
                        anchors.verticalCenter: parent.verticalCenter
                        active: clockPopup.visible
                        onClicked: root.togglePopup(clockPopup)
                    }
                }

                // ── Right: system buttons ─────────────────────────────
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
                        active: notificationCenter.visible
                        onClicked: root.togglePopup(notificationCenter)
                    }

                    NetworkButton {
                        id: networkButton
                        active: networkPopup.visible
                        onClicked: root.togglePopup(networkPopup)
                    }

                    BluetoothButton {
                        id: bluetoothButton
                        active: bluetoothPopup.visible
                        onClicked: root.togglePopup(bluetoothPopup)
                    }

                    DisplayButton {
                        id: displayButton
                        active: displayPopup.visible || wallpaperPicker.visible
                        onClicked: root.togglePopup(displayPopup)
                    }

                    AudioButton {
                        id: audioButton
                        active: audioPopup.visible
                        onClicked: root.togglePopup(audioPopup)
                    }

                    BatteryButton {
                        id: batteryButton
                        active: powerPopup.visible
                        onClicked: root.togglePopup(powerPopup)
                    }

                    PowerButton {
                        id: powerButton
                        active: powerMenuPopup.visible
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

            MediaPopup {
                id: mediaPopup
                anchorItem: mediaWidget
            }

            PowerMenuPopup {
                id: powerMenuPopup
                anchorItem: powerButton
            }
        }
    }
}
