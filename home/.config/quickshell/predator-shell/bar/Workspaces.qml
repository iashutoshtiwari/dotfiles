import QtQuick

import Quickshell.Hyprland

import qs.theme

Item {
    id: root

    readonly property int activeWorkspaceIndex:
        Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id >= 1
            ? Math.min(4, Hyprland.focusedWorkspace.id - 1)
            : 0

    implicitWidth: workspaceSlots.width
    implicitHeight: 28

    Item {
        id: workspaceSlots

        anchors.verticalCenter: parent.verticalCenter
        width: 5 * Theme.workspaceSlot - Theme.spacingSm
        height: parent.height

        // One accent marker travels between fixed slots so switching workspace
        // never changes layout or starts five competing animations.
        Rectangle {
            z: 0
            x: root.activeWorkspaceIndex * Theme.workspaceSlot + 6.5
            anchors.verticalCenter: parent.verticalCenter

            width: Theme.workspaceActiveDot
            height: width
            radius: width / 2
            color: Theme.accent

            Behavior on x {
                NumberAnimation {
                    duration: Theme.animationNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.fill: parent
            spacing: Theme.spacingSm

            Repeater {
                model: 5

                delegate: Item {
                    id: workspace

                    required property int index

                    readonly property int workspaceId: index + 1
                    readonly property bool active:
                        Hyprland.focusedWorkspace !== null
                        && Hyprland.focusedWorkspace.id === workspaceId

                    z: 1
                    width: Theme.workspaceSlot - Theme.spacingSm
                    height: parent.height

                    Rectangle {
                        anchors.centerIn: parent

                        width: workspace.active
                            ? Theme.workspaceActiveDot
                            : Theme.workspaceDot
                        height: width

                        // Workspace markers are the intentional exception to
                        // the shell's otherwise square geometry.
                        radius: width / 2
                        color: {
                            if (workspace.active)
                                return "transparent";
                            return workspaceMouse.containsMouse
                                ? Theme.surface2
                                : Theme.surface1;
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animationFast
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: workspace.workspaceId
                        color: workspace.active ? Theme.crust : Theme.subtext0
                        font.family: Theme.shellFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: workspaceMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            const existing = Hyprland.workspaces.values.find(
                                candidate => candidate.id === workspace.workspaceId
                            );

                            if (existing) {
                                existing.activate();
                                return;
                            }

                            // Empty workspaces do not have model objects yet.
                            if (Hyprland.usingLua) {
                                Hyprland.dispatch(
                                    'hl.dsp.focus({ workspace = "'
                                    + workspace.workspaceId
                                    + '" })'
                                );
                            } else {
                                Hyprland.dispatch(
                                    "workspace " + workspace.workspaceId
                                );
                            }
                        }
                    }
                }
            }
        }
    }
}
