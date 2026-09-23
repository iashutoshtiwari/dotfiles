import QtQuick
import Quickshell.Hyprland

import qs.theme

Item {
    id: root

    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace?.id ?? 0
    readonly property int highestWorkspaceId: {
        let highest = 0;
        for (const workspace of Hyprland.workspaces.values) {
            if (workspace.id > highest)
                highest = workspace.id;
        }
        return highest;
    }
    // Always expose one empty slot after the highest known workspace. Visiting
    // it grows the strip again, so normal Hyprland workspaces are unbounded.
    readonly property int workspaceCount: Math.max(5, activeWorkspaceId, highestWorkspaceId) + 1
    readonly property int activeWorkspaceIndex: activeWorkspaceId > 0
        ? activeWorkspaceId - 1 : -1

    function workspaceObject(id: int): var {
        return Hyprland.workspaces.values.find(workspace => workspace.id === id) ?? null;
    }

    function activateWorkspace(id: int): void {
        const existing = workspaceObject(id);
        if (existing) {
            existing.activate();
            return;
        }
        if (Hyprland.usingLua)
            Hyprland.dispatch('hl.dsp.focus({ workspace = "' + id + '" })');
        else
            Hyprland.dispatch("workspace " + id);
    }

    implicitWidth: workspaceSlots.width
    implicitHeight: 28

    Item {
        id: workspaceSlots
        anchors.verticalCenter: parent.verticalCenter
        width: root.workspaceCount * Theme.workspaceSlot - Theme.spacingSm
        height: parent.height

        // The marker shares the compositor's 230ms directional settling time.
        Rectangle {
            z: 2
            visible: root.activeWorkspaceIndex >= 0
            x: root.activeWorkspaceIndex * Theme.workspaceSlot + 6.5
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.workspaceActiveDot
            height: width
            radius: width / 2
            color: Theme.lavender

            Behavior on x {
                NumberAnimation {
                    duration: Theme.motionSpatial
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.fill: parent
            spacing: Theme.spacingSm

            Repeater {
                model: root.workspaceCount

                Item {
                    id: slot
                    required property int index

                    readonly property int workspaceId: index + 1
                    readonly property var workspace: root.workspaceObject(workspaceId)
                    readonly property bool active: root.activeWorkspaceIndex === index
                    readonly property bool occupied: (workspace?.toplevels?.values?.length ?? 0) > 0
                    readonly property bool urgent: workspace?.urgent ?? false

                    width: Theme.workspaceSlot - Theme.spacingSm
                    height: parent.height

                    Rectangle {
                        anchors.fill: parent
                        color: slotMouse.containsMouse ? Theme.surface0 : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: slot.occupied ? Theme.workspaceDot : 6
                        height: width
                        radius: width / 2
                        color: slot.active ? "transparent"
                            : slot.urgent ? Theme.red
                            : slotMouse.containsMouse ? Theme.surface2
                            : slot.occupied ? Theme.subtext0 : Theme.overlay0

                        Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: slotMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activateWorkspace(slot.workspaceId)
                    }
                }
            }
        }
    }
}
