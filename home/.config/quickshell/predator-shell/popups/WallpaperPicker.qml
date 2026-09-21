import QtQuick
import Quickshell
import Quickshell.Io

import qs.theme
import qs.services

PopupWindow {
    id: root

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

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

    Rectangle {
        anchors.fill: parent

        color: Theme.base
        border.width: 1
        border.color: Theme.surface0
        radius: Theme.radius

        Column {
            anchors {
                fill: parent
                margins: 14
            }

            spacing: 12

            // HEADER ROW
            Item {
                width: parent.width
                height: 32

                Column {
                    anchors {
                        left: parent.left
                        right: headerBtns.left
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    Text {
                        text: "WALLPAPERS"
                        font.family: Theme.shellFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: WallpaperService.wallpaperCount + " available in ~/Pictures/Wallpapers"
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.subtext0
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }

                Row {
                    id: headerBtns
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 6

                    // OPEN FOLDER BUTTON
                    Rectangle {
                        width: 74
                        height: 26
                        color: openFolderMouse.containsMouse ? Theme.surface1 : Theme.surface0
                        radius: Theme.radius

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "󰉋"
                                font.family: Theme.shellFont
                                font.pixelSize: 11
                                color: Theme.lavender
                            }

                            Text {
                                text: "Folder"
                                font.family: Theme.shellFont
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: Theme.text
                            }
                        }

                        MouseArea {
                            id: openFolderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: WallpaperService.openFolder()
                        }
                    }

                    // CLOSE BUTTON
                    Rectangle {
                        width: 26
                        height: 26
                        color: closeMouse.containsMouse ? Theme.surface1 : Theme.surface0
                        radius: Theme.radius

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: Theme.shellFont
                            font.pixelSize: 12
                            color: Theme.subtext0
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.visible = false
                        }
                    }
                }
            }

            // SEPARATOR
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

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
                            border.width: modelData.isCurrent ? 2 : 1
                            border.color: modelData.isCurrent
                                ? Theme.lavender
                                : (cardMouse.containsMouse ? Theme.surface1 : Theme.surface0)
                            radius: Theme.radius

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
                                        font.family: Theme.shellFont
                                        font.pixelSize: 10
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
