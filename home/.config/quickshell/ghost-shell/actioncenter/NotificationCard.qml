// NotificationCard.qml
// Individual notification row in the Action Center drawer.
// Uses flat rows with a left urgency indicator rather than heavy bordered cards.
// Designed to be extended: timestamp, image thumbnail, grouped actions.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs.theme
import qs.services
import qs.components

Item {
    id: root

    required property var notif

    // Emitted after the exit animation completes so the list can remove the item.
    signal dismissRequested()

    implicitWidth: 392
    implicitHeight: cardContent.implicitHeight + Theme.spacingMd * 2

    // ── Urgency accent on left edge ───────────────────────────────────
    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: Theme.activeRail
        color: root.notif?.urgency === 2 ? Theme.red
            : root.notif?.urgency === 1 ? Theme.lavender
            : Theme.surface1
    }

    // ── Hover surface ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: cardMouse.containsMouse ? Theme.surface0 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
    }

    // ── Notification content ──────────────────────────────────────────
    ColumnLayout {
        id: cardContent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.spacingMd
            leftMargin: Theme.spacingLg       // offset past the urgency bar
            topMargin: Theme.spacingMd
        }
        spacing: Theme.spacingXs

        // Header row: app icon + app name + timestamp + dismiss
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            IconImage {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                Layout.alignment: Qt.AlignVCenter
                source: root.notif?.appIcon ? Quickshell.iconPath(root.notif.appIcon) : ""
                visible: status === Image.Ready
            }

            Text {
                Layout.fillWidth: true
                text: root.notif?.appName || "Notification"
                elide: Text.ElideRight
                font.family: Theme.appFont
                font.pixelSize: Theme.fontCaption
                font.weight: Font.Medium
                color: root.notif?.urgency === 2 ? Theme.red : Theme.lavender
            }

            // Dismiss button — small, unobtrusive
            IconButton {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                icon: "󰅖"
                danger: true
                onClicked: root.dismissRequested()
            }
        }

        // Summary / title
        Text {
            Layout.fillWidth: true
            text: root.notif?.summary || ""
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.family: Theme.appFont
            font.pixelSize: Theme.fontBodyStrong
            font.weight: Font.Medium
            color: Theme.text
            visible: text.length > 0
        }

        // Body
        Text {
            Layout.fillWidth: true
            text: root.notif?.body || ""
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.family: Theme.appFont
            font.pixelSize: Theme.fontCaption
            color: Theme.subtext1
            visible: text.length > 0
        }

        // Action buttons — only for live notifications with actions
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm
            visible: (root.notif?.actions?.length ?? 0) > 0

            Repeater {
                model: root.notif?.actions || []

                delegate: Rectangle {
                    id: actionBtn
                    required property var modelData

                    implicitWidth: actionLabel.implicitWidth + Theme.spacingMd
                    implicitHeight: 22
                    color: actionMouse.containsMouse ? Theme.surface1 : Theme.surface0
                    radius: Theme.radius

                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: actionBtn.modelData?.text || ""
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontCaption
                        font.weight: Font.Medium
                        color: Theme.lavender
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            actionBtn.modelData?.invoke();
                        }
                    }
                }
            }
        }
    }

    // Passive hover detection for card background (no accepted buttons)
    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
