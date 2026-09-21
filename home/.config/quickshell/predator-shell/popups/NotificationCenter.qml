import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root
    property Item anchorItem
    readonly property int notificationCount: NotificationService.trackedNotifications?.values?.length ?? 0

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide
    implicitWidth: Theme.popupStandard
    implicitHeight: Math.ceil((root.notificationCount > 0 ? 480 : 280) / 4) * 4
    color: "transparent"
    grabFocus: true

    onVisibleChanged: if (visible) NotificationService.markAllRead()

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spacingMd

            PopupHeader {
                Layout.fillWidth: true
                icon: NotificationService.dnd ? "󰂛" : "󰂚"
                title: "Notifications"
                subtitle: NotificationService.dnd ? "Do not disturb is on"
                    : root.notificationCount === 0 ? "You're all caught up"
                    : root.notificationCount + (root.notificationCount === 1 ? " notification" : " notifications")
                actionIcon: NotificationService.dnd ? "󰂛" : "󰂚"
                onActionClicked: NotificationService.toggleDnd()
            }

            Divider { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                visible: root.notificationCount > 0
                SectionLabel { Layout.fillWidth: true; text: "Recent" }
                Text {
                    text: "Clear all"
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textSmall
                    color: Theme.subtext0
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: NotificationService.clearAll() }
                }
            }

            EmptyState {
                Layout.alignment: Qt.AlignCenter
                visible: root.notificationCount === 0
                icon: "󰂚"
                message: "You're all caught up"
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.notificationCount > 0
                clip: true
                spacing: Theme.spacingSm
                model: NotificationService.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData
                    width: listView.width
                    implicitHeight: cardContent.implicitHeight + Theme.spacingLg
                    color: cardMouse.containsMouse ? Theme.surface0 : Theme.base

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: 2
                        color: card.modelData?.urgency === 2 ? Theme.red
                            : card.modelData?.urgency === 1 ? Theme.lavender : Theme.surface2
                    }

                    ColumnLayout {
                        id: cardContent
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.spacingSm; leftMargin: Theme.spacingMd }
                        spacing: Theme.spacingXs

                        RowLayout {
                            Layout.fillWidth: true
                            IconImage {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                source: card.modelData?.appIcon ? Quickshell.iconPath(card.modelData.appIcon) : ""
                                visible: status === Image.Ready
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData?.appName || "Notification"
                                elide: Text.ElideRight
                                font.family: Theme.appFont
                                font.pixelSize: Theme.textSmall
                                font.weight: Font.Medium
                                color: Theme.lavender
                            }
                            IconButton { icon: "󰅖"; foreground: Theme.subtext0; onClicked: NotificationService.dismiss(card.modelData) }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: card.modelData?.summary || ""
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            font.family: Theme.appFont
                            font.pixelSize: Theme.textBodyStrong
                            font.weight: Font.Medium
                            color: Theme.text
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            text: card.modelData?.body || ""
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            font.family: Theme.appFont
                            font.pixelSize: Theme.textSmall
                            color: Theme.subtext1
                        }
                        RowLayout {
                            visible: card.modelData?.actions?.length > 0
                            spacing: Theme.spacingSm
                            Repeater {
                                model: card.modelData?.actions || []
                                Rectangle {
                                    required property var modelData
                                    implicitWidth: actionText.implicitWidth + Theme.spacingMd
                                    implicitHeight: 24
                                    color: actionMouse.containsMouse ? Theme.surface1 : Theme.surface0
                                    Text { id: actionText; anchors.centerIn: parent; text: parent.modelData?.text || ""; font.family: Theme.appFont; font.pixelSize: Theme.textSmall; font.weight: Font.Medium; color: Theme.lavender }
                                    MouseArea { id: actionMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.modelData?.invoke() }
                                }
                            }
                        }
                    }
                    MouseArea { id: cardMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                }
            }
        }
    }
}
