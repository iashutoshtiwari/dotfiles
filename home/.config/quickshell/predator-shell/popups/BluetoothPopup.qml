import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root
    property Item anchorItem

    readonly property var sortedDevices: BluetoothService.devices.slice().sort((a, b) => {
        if (a.connected !== b.connected) return a.connected ? -1 : 1;
        if (a.paired !== b.paired) return a.paired ? -1 : 1;
        return (a.name || "").localeCompare(b.name || "");
    })

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide
    implicitWidth: Theme.popupWide
    // Grow for real content instead of leaving a large empty scan panel.
    implicitHeight: Math.ceil((220 + Math.min(4, root.sortedDevices.length) * 48) / 4) * 4
    color: "transparent"
    grabFocus: true

    onVisibleChanged: if (!visible) BluetoothService.stopDiscovery()

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spacingMd

            PopupHeader {
                Layout.fillWidth: true
                icon: BluetoothService.enabled ? "󰂯" : "󰂲"
                title: "Bluetooth"
                subtitle: !BluetoothService.available ? "No adapter available"
                    : !BluetoothService.enabled ? "Off"
                    : BluetoothService.connectedCount + " connected"
                actionIcon: BluetoothService.enabled ? "󰂯" : "󰂲"
                actionEnabled: BluetoothService.available
                onActionClicked: BluetoothService.setEnabled(!BluetoothService.enabled)
            }

            Divider { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                visible: BluetoothService.enabled

                SectionLabel {
                    Layout.fillWidth: true
                    text: BluetoothService.connectedCount > 0 ? "Devices" : "Available devices"
                }
                Text {
                    text: BluetoothService.discovering ? "Scanning…" : "Scan"
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textSmall
                    font.weight: Font.Medium
                    color: BluetoothService.discovering ? Theme.sapphire : Theme.lavender
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothService.toggleDiscovery()
                    }
                }
            }

            ListView {
                id: deviceList
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: BluetoothService.enabled && root.sortedDevices.length > 0
                clip: true
                spacing: 2
                model: ScriptModel { values: root.sortedDevices }

                delegate: PopupRow {
                    required property var modelData
                    width: deviceList.width
                    icon: modelData.connected ? "󰂱" : "󰂯"
                    label: modelData.name || modelData.deviceName || modelData.address
                    description: modelData.pairing ? "Pairing…"
                        : modelData.connected ? "Connected"
                        : modelData.paired ? "Paired" : "Available"
                    value: modelData.batteryAvailable
                        ? Math.round(modelData.battery * 100) + "%"
                        : modelData.connected ? "Disconnect"
                        : modelData.paired ? "Connect" : "Pair"
                    selected: modelData.connected
                    statusColor: modelData.connected ? Theme.green : Theme.subtext0
                    onClicked: {
                        if (modelData.pairing) BluetoothService.cancelPair(modelData);
                        else if (modelData.connected) BluetoothService.disconnectDevice(modelData);
                        else if (modelData.paired) BluetoothService.connectDevice(modelData);
                        else BluetoothService.pairDevice(modelData);
                    }
                }
            }

            EmptyState {
                Layout.alignment: Qt.AlignCenter
                visible: BluetoothService.enabled && root.sortedDevices.length === 0
                icon: BluetoothService.discovering ? "󰂯" : "󰂲"
                message: BluetoothService.discovering ? "Scanning for devices…" : "No devices found"
            }

            EmptyState {
                Layout.alignment: Qt.AlignCenter
                visible: !BluetoothService.enabled
                icon: "󰂲"
                message: BluetoothService.available ? "Bluetooth is off" : "Bluetooth unavailable"
            }
        }
    }
}
