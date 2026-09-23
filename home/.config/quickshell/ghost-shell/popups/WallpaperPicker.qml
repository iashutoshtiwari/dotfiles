import QtQuick
import Quickshell
import Quickshell.Io

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: 400
    implicitHeight: 480

    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (visible) {
            WallpaperService.refresh();
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            root.visible = !root.visible;
        }

        function open(): void {
            root.visible = true;
        }

        function close(): void {
            root.visible = false;
        }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        Column {
            anchors {
                fill: parent
                margins: 14
            }

            spacing: 12

            // HEADER ROW
            SectionHeader {
                width: parent.width
                title: "WALLPAPERS"
                subtitle: WallpaperService.wallpaperCount + " available in ~/Pictures/Wallpapers"

                ControlButton {
                    icon: "󰉋"
                    text: "Folder"
                    compact: true
                    onClicked: WallpaperService.openFolder()
                }

                IconButton {
                    icon: "󰅖"
                    danger: true
                    onClicked: root.visible = false
                }
            }

            Divider { width: parent.width }

            // WALLPAPERS GRID SCROLLER
            Flickable {
                width: parent.width
                height: parent.height - y - 10
                contentWidth: width
                contentHeight: flow.implicitHeight
                clip: true

                Flow {
                    id: flow
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: WallpaperService.wallpapers

                        delegate: Rectangle {
                            required property var modelData

                            width: (flow.width - 10) / 2
                            height: 138

                            color: Theme.surface0
                            border.width: 1
                            border.color: modelData.isCurrent
                                ? Theme.lavender
                                : (cardMouse.containsMouse ? Theme.surface1 : Theme.surface0)
                            radius: Theme.radius

                            // Ghost signature active rail
                            Rectangle {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                height: Theme.activeRail
                                color: Theme.lavender
                                visible: modelData.isCurrent
                                z: 2
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 4

                                // THUMBNAIL IMAGE
                                Rectangle {
                                    width: parent.width
                                    height: 100
                                    color: Theme.crust
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: "file://" + modelData.path
                                        sourceSize.width: 190
                                        sourceSize.height: 108
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                    }

                                    // ACTIVE BADGE OVERLAY
                                    Rectangle {
                                        visible: modelData.isCurrent
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        width: 54
                                        height: 18
                                        color: Theme.base
                                        radius: Theme.radius

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰄲 Active"
                                            font.family: Theme.shellFont
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            color: Theme.lavender
                                        }
                                    }
                                }

                                // FILENAME CAPTION
                                Row {
                                    width: parent.width
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Text {
                                        width: parent.width
                                        text: modelData.name
                                        font.family: Theme.appFont
                                        font.pixelSize: Theme.fontCaption
                                        font.weight: modelData.isCurrent ? Font.DemiBold : Font.Medium
                                        color: modelData.isCurrent ? Theme.lavender : Theme.text
                                        elide: Text.ElideMiddle
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.selectWallpaper(modelData.path)
                            }
                        }
                    }
                }
            }
        }
    }
}
