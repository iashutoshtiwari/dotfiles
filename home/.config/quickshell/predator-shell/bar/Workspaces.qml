import QtQuick

import Quickshell.Hyprland

import qs.theme

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: 28

    Row {
        id: row

        anchors.verticalCenter: parent.verticalCenter

        spacing: 4

        Repeater {
            model: 5

            delegate: Item {
                id: workspace

                required property int index

                property int workspaceId: index + 1

                property bool active:
                    Hyprland.focusedWorkspace !== null
                    && Hyprland.focusedWorkspace.id === workspaceId

                width: 27
                height: 28

                Rectangle {
                    anchors.centerIn: parent

                    width: 22
                    height: 22

                    // It's a workspace dot, so this is the one place
                    // where circular geometry is intentional.
                    radius: 11

                    color: workspace.active
                        ? Theme.accent
                        : "transparent"

                    border.width: workspace.active ? 0 : 1
                    border.color: Theme.surface1

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animationFast
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: workspace.workspaceId

                    font.family: Theme.shellFont
                    font.pixelSize: 11
                    font.weight: Font.DemiBold

                    color: workspace.active
                        ? Theme.crust
                        : Theme.subtext0
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        const existing =
                            Hyprland.workspaces.values.find(
                                ws => ws.id === workspace.workspaceId
                            );

                        if (existing) {
                            existing.activate();
                            return;
                        }

                        // Empty workspace fallback.
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
