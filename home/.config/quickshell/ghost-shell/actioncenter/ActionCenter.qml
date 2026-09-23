// ActionCenter.qml
// Right-side Action Center drawer — a permanent top-level shell surface.
//
// Architecture:
//   PanelWindow (Overlay layer, full screen, transparent)
//   ├── dim backdrop (Rectangle, full screen)
//   └── drawer surface (Rectangle, right-aligned, slides in from right)
//       ├── ActionCenter header (title, DND toggle)
//       └── Content area (extensible)
//           └── NotificationList (initial module)
//           // Future: BluetoothControl, DisplaysControl, etc.
//
// One ActionCenter instance is created per screen inside Bar.qml's Variants scope.
// This binds each drawer to its monitor. Only one drawer opens globally at a time
// (enforced by Bar's popup coordinator via present()/dismiss() calls).
//
// Motion: QML-owned horizontal slide (Theme.motionSpatial open, Theme.motionNormal close).
// Hyprland must have no_anim for ghost-action-center namespace (see hyprland.lua).
//
// Popup coordinator interface:
//   open     property bool  — true when drawer is open
//   present()              — open the drawer
//   dismiss()              — close the drawer
// Bar.qml checks `actionCenterOverlay.open` (not .visible) when deciding whether
// to close this surface before opening another popup.
//
// IPC: qs ipc -c ghost-shell call actionCenter toggle|open|close

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

import qs.theme
import qs.services

PanelWindow {
    id: root

    // ── Identity ──────────────────────────────────────────────────────
    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ghost-action-center"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // ── Geometry: full-screen transparent overlay ─────────────────────
    exclusiveZone: 0
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Exclusive zone from the top bar (exclusiveZone = barHeight + barMargin = 46,
    // plus top margin = 8 -> 54 total reserved) is automatically respected
    // by Hyprland's layer surface arrangement, placing the top anchor at y = 54.
    margins {
        top: 0
        left: 0
        right: 0
        bottom: 0
    }

    // ── Open/close state ──────────────────────────────────────────────
    property bool open: false

    // Track animation completion so we can hide the window after close.
    // The window stays visible during the close animation; once the drawer
    // has fully exited and the backdrop has faded, the window can be hidden.
    readonly property bool animationActive: backdropRect.opacity > 0.001 || drawer.drawerX < root.width

    // Hide the window when closed and animation has finished.
    // Keep alive when open or animating so motion is not cut short.
    visible: open || animationActive

    function present(): void {
        open = true;
        NotificationService.markAllRead();
        NotificationService.actionCenterOpen = true;
    }

    function dismiss(): void {
        open = false;
        NotificationService.actionCenterOpen = false;
    }

    function toggle(): void {
        if (open)
            dismiss();
        else
            present();
    }

    // ── IPC: actionCenter target ──────────────────────────────────────
    IpcHandler {
        target: "actionCenter"

        function toggle(): void { root.toggle() }
        function open(): void   { root.present() }
        function close(): void  { root.dismiss() }
    }

    // ── Workspace dismiss ─────────────────────────────────────────────
    // Close when the user switches workspace. Uses native Quickshell Hyprland
    // signals — no polling, no subprocess.
    property int _openedWorkspaceId: -1

    onOpenChanged: {
        if (open)
            _openedWorkspaceId = Hyprland.focusedWorkspace?.id ?? -1;
    }

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged(): void {
            if (!root.open)
                return;
            const newId = Hyprland.focusedWorkspace?.id ?? -1;
            if (newId !== root._openedWorkspaceId && newId >= 0)
                root.dismiss();
        }
    }

    // ── Dim backdrop ──────────────────────────────────────────────────
    Rectangle {
        id: backdropRect
        anchors.fill: parent
        color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 1)

        // Subtle dimming without making desktop disappear
        opacity: root.open ? Theme.backdropOpacity : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? Theme.motionSpatial : Theme.motionNormal
                easing.type: root.open ? Easing.OutCubic : Easing.InCubic
            }
        }

        // Clicking backdrop closes the drawer
        MouseArea {
            anchors.fill: parent
            enabled: root.open
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismiss()
        }
    }

    // ── Drawer surface ────────────────────────────────────────────────
    Rectangle {
        id: drawer

        readonly property real drawerWidth: Math.min(Theme.actionCenterWidth, root.width - Theme.barMargin * 2)

        // drawerX drives the Behavior-animated position.
        // Separated from x so we can read the animated value for animationActive.
        property real drawerX: root.open
            ? root.width - drawerWidth - Theme.barMargin
            : root.width

        // Animate the position change smoothly.
        Behavior on drawerX {
            NumberAnimation {
                duration: root.open ? Theme.motionSpatial : Theme.motionNormal
                easing.type: root.open ? Easing.OutCubic : Easing.InCubic
            }
        }

        x: drawerX
        width: drawerWidth
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.barMargin

        // Block all pointer events so backdrop MouseArea is not triggered
        // by clicks inside the drawer.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
            // Absorb all button events; propagation stops here.
            onClicked: mouse => mouse.accepted = true
            onPressed: mouse => mouse.accepted = true
            onReleased: mouse => mouse.accepted = true
        }

        // ── Surface ───────────────────────────────────────────────────
        color: Theme.mantle
        border.width: Theme.borderWidth
        border.color: Theme.surface1
        radius: Theme.radius

        // ── Keyboard: Escape closes ───────────────────────────────────
        Keys.onEscapePressed: root.dismiss()
        focus: root.open

        // ── Drawer content ─────────────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ─────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacingMd
                Layout.rightMargin: Theme.spacingSm
                Layout.topMargin: Theme.spacingMd
                Layout.bottomMargin: Theme.spacingMd
                spacing: Theme.spacingSm

                Column {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Action Center"
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontHeading
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: {
                            const n = NotificationService.trackedNotifications?.values?.length ?? 0;
                            if (NotificationService.dnd)
                                return "Do not disturb";
                            if (n === 0)
                                return "No notifications";
                            return n + (n === 1 ? " notification" : " notifications");
                        }
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontCaption
                        color: NotificationService.dnd ? Theme.red : Theme.subtext0
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                    }
                }

                // DND toggle button
                Rectangle {
                    id: dndBtn
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    color: dndMouse.containsMouse
                        ? Theme.surface0
                        : (NotificationService.dnd
                            ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15)
                            : "transparent")
                    radius: Theme.radius

                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                    Text {
                        anchors.centerIn: parent
                        text: NotificationService.dnd ? "󰂛" : "󰂚"
                        font.family: Theme.iconFont
                        font.pixelSize: 16
                        color: NotificationService.dnd ? Theme.red : Theme.subtext0
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                    }

                    MouseArea {
                        id: dndMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.toggleDnd()
                    }
                }
            }

            // ── Divider ─────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.surface0
            }

            // ── Content area (extensible) ──────────────────────────────
            // The notification section fills all remaining space.
            // Future modules (Bluetooth, Displays, Printers, etc.) are
            // inserted ABOVE NotificationList, each as a fixed-height
            // Item with its own section header and content.
            //
            // Pattern for future module:
            //   BluetoothControlSection { Layout.fillWidth: true }
            //   Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }
            //   NotificationList { Layout.fillWidth: true; Layout.fillHeight: true }

            NotificationList {
                id: notifSection
                Layout.fillWidth: true
                Layout.fillHeight: true
                drawerOpen: root.open
            }
        }
    }
}
