import QtQuick
import Quickshell
import Quickshell.Io

import qs.theme
import qs.popups
import qs.actioncenter

// Bar creates one instance of the bar panel and its associated Action Center
// overlay per screen. This ensures the Action Center opens on the same monitor
// as the button that triggered it.

Scope {
    Variants {
        model: Quickshell.screens

        // ── Per-screen scope ─────────────────────────────────────────────
        Scope {
            id: perScreen

            required property var modelData

            // Reference to the Action Center overlay for this screen.
            // Bar uses this to include it in allPopups coordination.
            property var actionCenterRef: actionCenterOverlay

            // ── Action Center overlay (full-screen, Overlay layer) ────────
            // This is a separate PanelWindow from the bar, living at Overlay
            // layer so it draws above normal windows without disturbing tiling.
            ActionCenter {
                id: actionCenterOverlay
                modelData: perScreen.modelData
            }

            // ── Top bar panel ─────────────────────────────────────────────
            PanelWindow {
                id: root

                screen: perScreen.modelData

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

                // ── Popup coordinator ─────────────────────────────────────
                // allPopups includes all transient surfaces on this screen.
                // Action Center is included so opening any popup closes the
                // drawer, and opening the drawer closes all popups.
                readonly property var allPopups: [
                    actionCenterOverlay,
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

                // Returns true if a surface is currently logically open.
                // ActionCenter uses .open; regular PopupWindows use .visible.
                function isOpen(surface): bool {
                    if (!surface) return false;
                    if (typeof surface.open === "boolean")
                        return surface.open;
                    return surface.visible ?? false;
                }

                function closeOne(surface): void {
                    if (!surface) return;
                    if (surface.dismiss)
                        surface.dismiss();
                    else
                        surface.visible = false;
                }

                function togglePopup(targetPopup): void {
                    if (!targetPopup)
                        return;
                    const wasOpen = root.isOpen(targetPopup);
                    // Close all other surfaces before toggling target.
                    for (let i = 0; i < allPopups.length; i++) {
                        const popup = allPopups[i];
                        if (popup && popup !== targetPopup && root.isOpen(popup))
                            root.closeOne(popup);
                    }
                    if (wasOpen)
                        root.closeOne(targetPopup);
                    else if (targetPopup.present)
                        targetPopup.present();
                    else
                        targetPopup.visible = true;
                }

                function closeAllPopups(): void {
                    for (let i = 0; i < allPopups.length; i++) {
                        const p = allPopups[i];
                        if (p && root.isOpen(p))
                            root.closeOne(p);
                    }
                }


                IpcHandler {
                    target: "popups"

                    function closeAll(): void {
                        root.closeAllPopups();
                    }

                    function toggle(name: string): void {
                        const map = {
                            "actioncenter": actionCenterOverlay,
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

                    // ── Left: workspaces + mode indicator ─────────────────
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

                    // ── Center: Media + Weather + Clock ────────────────────
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

                    // ── Right: system buttons (left → right order) ─────────
                    // Order: tray | network | bluetooth | display | audio |
                    //        battery | power | [action center — rightmost]
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

                        // Action Center — rightmost bar button
                        ActionCenterButton {
                            id: actionCenterButton
                            anchors.verticalCenter: parent.verticalCenter
                            active: actionCenterOverlay.open
                            onClicked: root.togglePopup(actionCenterOverlay)
                        }
                    }
                }

                // ── Per-screen popup surfaces ──────────────────────────────
                // These are anchored to their bar buttons on this screen.

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
}
