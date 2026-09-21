import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import qs.theme
import qs.services

PanelWindow {
    id: root

    screen: Quickshell.screens[0]
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "predator-notifications"

    exclusiveZone: 0
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 48
        right: 12
    }

    implicitWidth: 360
    implicitHeight: toastColumn.implicitHeight

    visible: activeToasts.length > 0

    property var activeToasts: []

    function addToast(notif): void {
        if (!notif)
            return;
        activeToasts = [notif, ...activeToasts.filter(t => t && t.id !== notif.id)];
    }

    function removeToast(notifId): void {
        activeToasts = activeToasts.filter(t => t && t.id !== notifId);
    }

    Connections {
        target: NotificationService

        function onToastRequested(notif): void {
            root.addToast(notif);
        }
    }

    Column {
        id: toastColumn
        width: parent.width
        spacing: 8

        Repeater {
            model: root.activeToasts

            delegate: Rectangle {
                id: toastCard
                required property var modelData

                width: toastColumn.width
                implicitHeight: cardContent.implicitHeight + 20

                color: Theme.base
                border.width: 1
                border.color: modelData && modelData.urgency === 2 ? Theme.red : Theme.surface0
                radius: Theme.radius

                // Urgency accent strip on left border
                Rectangle {
                    width: 3
                    height: parent.height
                    color: toastCard.modelData && toastCard.modelData.urgency === 2
                        ? Theme.red
                        : (toastCard.modelData && toastCard.modelData.urgency === 1 ? Theme.lavender : Theme.surface2)
                }

                Timer {
                    id: autoDismissTimer
                    interval: toastCard.modelData && toastCard.modelData.expireTimeout > 0
                        ? (toastCard.modelData.expireTimeout * 1000)
                        : (toastCard.modelData && toastCard.modelData.urgency === 2 ? 0 : 5000)
                    running: interval > 0
                    onTriggered: {
                        if (toastCard.modelData)
                            root.removeToast(toastCard.modelData.id);
                    }
                }

                Column {
                    id: cardContent
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 10
                        leftMargin: 14
                    }
                    spacing: 6

                    // Header: Icon + App Name + Close Button
                    Row {
                        width: parent.width

                        Row {
                            width: parent.width - 24
                            spacing: 8

                            IconImage {
                                id: appIconImg
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                source: toastCard.modelData && toastCard.modelData.appIcon
                                    ? Quickshell.iconPath(toastCard.modelData.appIcon)
                                    : ""
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                font.family: Theme.shellFont
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: Theme.lavender
                                text: (toastCard.modelData && toastCard.modelData.appName) || "Notification"
                                elide: Text.ElideRight
                            }
                        }

                        // Close button
                        Rectangle {
                            width: 20
                            height: 20
                            color: closeMouse.containsMouse ? Theme.surface0 : "transparent"
                            radius: Theme.radius

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.shellFont
                                font.pixelSize: 12
                                color: Theme.subtext0
                                text: "󰅖"
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (toastCard.modelData) {
                                        toastCard.modelData.dismiss();
                                        root.removeToast(toastCard.modelData.id);
                                    }
                                }
                            }
                        }
                    }

                    // Summary
                    Text {
                        width: parent.width
                        font.family: Theme.shellFont
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.text
                        text: (toastCard.modelData && toastCard.modelData.summary) || ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    // Body
                    Text {
                        width: parent.width
                        font.family: Theme.shellFont
                        font.pixelSize: 11
                        color: Theme.subtext1
                        text: (toastCard.modelData && toastCard.modelData.body) || ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }

                    // Actions Row
                    Row {
                        width: parent.width
                        spacing: 6
                        visible: toastCard.modelData && toastCard.modelData.actions && toastCard.modelData.actions.length > 0

                        Repeater {
                            model: (toastCard.modelData && toastCard.modelData.actions) || []

                            delegate: Rectangle {
                                id: actionBtn
                                required property var modelData

                                implicitWidth: actionLabel.implicitWidth + 16
                                height: 24
                                color: actionMouse.containsMouse ? Theme.surface1 : Theme.surface0
                                radius: Theme.radius

                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    font.family: Theme.shellFont
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: Theme.lavender
                                    text: (actionBtn.modelData && actionBtn.modelData.text) || ""
                                }

                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (actionBtn.modelData) {
                                            actionBtn.modelData.invoke();
                                        }
                                        if (toastCard.modelData) {
                                            root.removeToast(toastCard.modelData.id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
