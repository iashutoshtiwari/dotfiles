import QtQuick
import Quickshell

import qs.theme
import qs.services

PopupWindow {
    id: root

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

    implicitWidth: 392
    implicitHeight: 460

    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (!visible)
            BluetoothService.stopDiscovery();
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.base
        border.width: 1
        border.color: Theme.surface0
        radius: 0

        Column {
            anchors {
                fill: parent
                margins: 16
            }

            spacing: 12

            Row {
                width: parent.width
                height: 24

                Text {
                    width: parent.width - 90

                    text: "BLUETOOTH"

                    font.family: Theme.shellFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold

                    color: Theme.text
                }

                Text {
                    width: 90

                    horizontalAlignment: Text.AlignRight

                    text: BluetoothService.enabled
                        ? "ON"
                        : "OFF"

                    font.family: Theme.shellFont
                    font.pixelSize: 10
                    font.weight: Font.DemiBold

                    color: BluetoothService.enabled
                        ? Theme.lavender
                        : Theme.overlay1

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            BluetoothService.setEnabled(
                                !BluetoothService.enabled
                            )
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            Row {
                width: parent.width
                visible: BluetoothService.enabled

                Text {
                    width: parent.width - 110

                    text: BluetoothService.connectedCount > 0
                        ? BluetoothService.connectedCount
                            + " DEVICE"
                            + (BluetoothService.connectedCount === 1
                                ? ""
                                : "S")
                            + " CONNECTED"
                        : "NO DEVICES CONNECTED"

                    font.family: Theme.shellFont
                    font.pixelSize: 9

                    color: Theme.overlay1
                }

                Text {
                    width: 110

                    horizontalAlignment: Text.AlignRight

                    text: BluetoothService.discovering
                        ? "STOP SCAN"
                        : "SCAN"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    font.weight: Font.DemiBold

                    color: Theme.lavender

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            BluetoothService.toggleDiscovery()
                    }
                }
            }

            ListView {
                id: deviceList

                visible: BluetoothService.enabled

                width: parent.width
                height: 340

                clip: true
                spacing: 3

                model: ScriptModel {
                    values:
                        BluetoothService.devices
                        .slice()
                        .sort((a, b) => {
                            if (a.connected !== b.connected)
                                return a.connected ? -1 : 1;

                            if (a.paired !== b.paired)
                                return a.paired ? -1 : 1;

                            return a.name.localeCompare(b.name);
                        })
                }

                delegate: Rectangle {
                    id: deviceRow

                    required property var modelData

                    width: deviceList.width
                    height: modelData.batteryAvailable
                        ? 54
                        : 44

                    color: modelData.connected
                        ? Theme.surface0
                        : "transparent"

                    border.width: 0

                    Text {
                        id: icon

                        anchors {
                            left: parent.left
                            leftMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.connected
                            ? "󰂱"
                            : "󰂯"

                        font.family: Theme.shellFont
                        font.pixelSize: 15

                        color: modelData.connected
                            ? Theme.lavender
                            : Theme.subtext0
                    }

                    Column {
                        anchors {
                            left: icon.right
                            leftMargin: 10
                            right: actionText.left
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 3

                        Text {
                            width: parent.width

                            text: modelData.name
                                || modelData.deviceName
                                || modelData.address

                            elide: Text.ElideRight

                            font.family: Theme.shellFont
                            font.pixelSize: 11
                            font.weight: modelData.connected
                                ? Font.DemiBold
                                : Font.Normal

                            color: modelData.connected
                                ? Theme.lavender
                                : Theme.text
                        }

                        Text {
                            width: parent.width

                            text: {
                                let parts = [];

                                if (modelData.connected)
                                    parts.push("CONNECTED");
                                else if (modelData.pairing)
                                    parts.push("PAIRING");
                                else if (modelData.paired)
                                    parts.push("PAIRED");
                                else
                                    parts.push("AVAILABLE");

                                if (modelData.batteryAvailable) {
                                    parts.push(
                                        Math.round(
                                            modelData.battery * 100
                                        ) + "%"
                                    );
                                }

                                return parts.join("  ·  ");
                            }

                            font.family: Theme.shellFont
                            font.pixelSize: 9

                            color: Theme.overlay1
                        }
                    }

                    Text {
                        id: actionText

                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                        text: {
                            if (modelData.pairing)
                                return "CANCEL";

                            if (modelData.connected)
                                return "DISCONNECT";

                            if (modelData.paired)
                                return "CONNECT";

                            return "PAIR";
                        }

                        font.family: Theme.shellFont
                        font.pixelSize: 9
                        font.weight: Font.DemiBold

                        color: Theme.lavender

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (modelData.pairing) {
                                    BluetoothService.cancelPair(
                                        modelData
                                    );

                                    return;
                                }

                                if (modelData.connected) {
                                    BluetoothService.disconnectDevice(
                                        modelData
                                    );

                                    return;
                                }

                                if (modelData.paired) {
                                    BluetoothService.connectDevice(
                                        modelData
                                    );

                                    return;
                                }

                                BluetoothService.pairDevice(
                                    modelData
                                );
                            }
                        }
                    }
                }
            }

            Item {
                visible: !BluetoothService.enabled

                width: parent.width
                height: 260

                Text {
                    anchors.centerIn: parent

                    text: "Bluetooth is disabled"

                    font.family: Theme.shellFont
                    font.pixelSize: 11

                    color: Theme.overlay1
                }
            }
        }
    }
}
