import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root
    property Item anchorItem
    property string page: "network"
    property var pendingNetwork: null
    property string connectionMessage: ""

    readonly property var sortedNetworks: NetworkService.wifiNetworks.slice().sort((a, b) => {
        if (a.connected !== b.connected) return a.connected ? -1 : 1;
        return b.signalStrength - a.signalStrength;
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
    implicitHeight: 512
    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (visible) {
            page = "network";
            pendingNetwork = null;
            connectionMessage = "";
            NetworkService.startScanning();
            NetworkService.refreshDetails();
        } else {
            pendingNetwork = null;
            passwordInput.text = "";
            NetworkService.stopScanning();
        }
    }

    function wifiIcon(strength: real): string {
        if (strength >= 0.75) return "󰤨";
        if (strength >= 0.50) return "󰤥";
        if (strength >= 0.25) return "󰤢";
        return "󰤟";
    }

    function chooseNetwork(network): void {
        connectionMessage = "";
        pendingNetwork = null;
        passwordInput.text = "";
        if (!network || network.connected) return;
        if (network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe) {
            NetworkService.connectNetwork(network);
            return;
        }
        if (network.security === WifiSecurityType.WpaPsk
                || network.security === WifiSecurityType.Wpa2Psk
                || network.security === WifiSecurityType.Sae) {
            pendingNetwork = network;
            Qt.callLater(() => passwordInput.forceActiveFocus());
            return;
        }
        connectionMessage = "This network requires manual setup";
    }

    Connections {
        target: NetworkService
        function onLastConnectionErrorChanged() {
            root.connectionMessage = NetworkService.lastConnectionError.length > 0
                ? "Could not connect" : "";
        }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        StackLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            currentIndex: root.page === "network" ? 0 : 1

            ColumnLayout {
                spacing: Theme.spacingMd

                PopupHeader {
                    Layout.fillWidth: true
                    icon: NetworkService.connected ? "󰤨" : "󰤮"
                    title: "Network"
                    subtitle: NetworkService.wiredConnected ? "Ethernet · Connected"
                        : NetworkService.wifiConnected ? NetworkService.ssid + " · Connected"
                        : NetworkService.wifiEnabled ? "Not connected" : "Wi-Fi off"
                    actionIcon: NetworkService.wifiEnabled ? "󰤨" : "󰤭"
                    actionEnabled: NetworkService.wifiHardwareEnabled
                    onActionClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
                }

                Divider { Layout.fillWidth: true }

                SectionLabel { text: NetworkService.connected ? "Current connection" : "Connection" }

                PopupRow {
                    Layout.fillWidth: true
                    icon: NetworkService.wiredConnected ? "󰈀" : root.wifiIcon(NetworkService.signalStrength)
                    label: NetworkService.wiredConnected ? "Ethernet" : NetworkService.ssid || "No active connection"
                    description: NetworkService.connected
                        ? (NetworkService.ipv4Address || "Connected") : "Offline"
                    value: NetworkService.wifiConnected ? "Disconnect" : ""
                    selected: NetworkService.connected
                    statusColor: NetworkService.connected ? Theme.green : Theme.overlay0
                    interactive: NetworkService.wifiConnected
                    onClicked: NetworkService.disconnectWifi()
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: NetworkService.wifiEnabled
                    SectionLabel { Layout.fillWidth: true; text: "Available networks" }
                    Text {
                        text: NetworkService.scanning ? "Scanning…" : "Rescan"
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textSmall
                        color: NetworkService.scanning ? Theme.sapphire : Theme.lavender
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NetworkService.startScanning()
                        }
                    }
                }

                ListView {
                    id: networkList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: NetworkService.wifiEnabled && root.sortedNetworks.length > 0
                    clip: true
                    spacing: 2
                    model: ScriptModel { values: root.sortedNetworks }

                    delegate: PopupRow {
                        required property var modelData
                        width: networkList.width
                        icon: root.wifiIcon(modelData.signalStrength)
                        label: modelData.name
                        description: modelData.connected ? "Connected"
                            : modelData.known ? "Saved network" : "Available"
                        value: modelData.security === WifiSecurityType.Open ? "" : "󰌾"
                        selected: modelData.connected
                        statusColor: Theme.overlay1
                        onClicked: root.chooseNetwork(modelData)

                        Connections {
                            target: modelData
                            function onConnectionFailed(reason) { root.connectionMessage = "Could not connect"; }
                        }
                    }
                }

                EmptyState {
                    Layout.alignment: Qt.AlignCenter
                    visible: NetworkService.wifiEnabled && root.sortedNetworks.length === 0
                    icon: NetworkService.scanning ? "󰤨" : "󰤭"
                    message: NetworkService.scanning ? "Scanning for networks…" : "No networks found"
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.connectionMessage.length > 0
                    text: root.connectionMessage
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textSmall
                    color: Theme.red
                }

                Divider { Layout.fillWidth: true }
                SectionLabel { text: "Advanced" }

                PopupRow {
                    Layout.fillWidth: true
                    icon: "󰒍"
                    label: "DNS"
                    description: NetworkService.ipv4Dns || "Automatic"
                    value: "Edit  󰅂"
                    interactive: NetworkService.connected
                    onClicked: root.page = "dns"
                }
                PopupRow {
                    Layout.fillWidth: true
                    icon: "󰩟"
                    label: NetworkService.activeInterface || "Interface"
                    description: NetworkService.ipv4Gateway.length > 0
                        ? "Gateway " + NetworkService.ipv4Gateway : "No gateway"
                    value: NetworkService.ipv4Address
                    interactive: false
                }
            }

            ColumnLayout {
                spacing: Theme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    IconButton { icon: "󰅁"; onClicked: root.page = "network" }
                    PopupHeader {
                        Layout.fillWidth: true
                        icon: "󰒍"
                        title: "DNS"
                        subtitle: NetworkService.ssid || NetworkService.activeInterface || "No active connection"
                    }
                }
                Divider { Layout.fillWidth: true }
                SectionLabel { text: "Presets" }

                Repeater {
                    model: [
                        { label: "Automatic", detail: "DHCP / router", value: "automatic" },
                        { label: "Cloudflare", detail: "1.1.1.1", value: "cloudflare" },
                        { label: "Google", detail: "8.8.8.8", value: "google" },
                        { label: "Quad9", detail: "9.9.9.9", value: "quad9" }
                    ]
                    PopupRow {
                        required property var modelData
                        Layout.fillWidth: true
                        icon: "󰒍"
                        label: modelData.label
                        value: modelData.detail
                        onClicked: NetworkService.applyDns(modelData.value, "")
                    }
                }

                SectionLabel { text: "Custom servers" }
                Rectangle {
                    Layout.fillWidth: true
                    height: 38
                    color: Theme.base
                    border.width: 1
                    border.color: customDns.activeFocus ? Theme.lavender : Theme.surface1
                    TextInput {
                        id: customDns
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textBody
                        color: Theme.text
                        selectionColor: Theme.lavender
                        selectedTextColor: Theme.crust
                        Keys.onReturnPressed: NetworkService.applyDns("custom", text)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: customDns.text.length === 0 && !customDns.activeFocus
                            text: "1.1.1.1, 1.0.0.1"
                            font.family: Theme.appFont
                            font.pixelSize: Theme.textBody
                            color: Theme.overlay0
                        }
                    }
                }
                PopupRow {
                    Layout.fillWidth: true
                    icon: "󰄬"
                    label: "Apply custom DNS"
                    value: NetworkService.dnsBusy ? "Applying…" : "Apply"
                    onClicked: NetworkService.applyDns("custom", customDns.text)
                }
                Text {
                    Layout.fillWidth: true
                    text: NetworkService.dnsStatus
                    visible: text.length > 0
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textSmall
                    color: text === "DNS applied" ? Theme.green : Theme.red
                }
                Item { Layout.fillHeight: true }
            }
        }

        Rectangle {
            id: passwordPanel
            visible: root.pendingNetwork !== null
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: Theme.popupPadding }
            height: 144
            color: Theme.base
            border.width: 1
            border.color: Theme.lavender

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingMd
                spacing: Theme.spacingSm
                Text {
                    Layout.fillWidth: true
                    text: "Connect to " + (root.pendingNetwork?.name ?? "")
                    elide: Text.ElideRight
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textBodyStrong
                    font.weight: Font.DemiBold
                    color: Theme.text
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 38
                    color: Theme.mantle
                    border.width: 1
                    border.color: passwordInput.activeFocus ? Theme.lavender : Theme.surface1
                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textBody
                        color: Theme.text
                        selectionColor: Theme.lavender
                        selectedTextColor: Theme.crust
                        Keys.onReturnPressed: {
                            NetworkService.connectWithPassword(root.pendingNetwork, text);
                            root.pendingNetwork = null;
                            text = "";
                        }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: Theme.spacingLg
                    Text {
                        text: "Cancel"
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textSmall
                        color: Theme.subtext0
                        MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: { root.pendingNetwork = null; passwordInput.text = ""; } }
                    }
                    Text {
                        text: "Connect"
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textSmall
                        font.weight: Font.DemiBold
                        color: Theme.lavender
                        MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: { NetworkService.connectWithPassword(root.pendingNetwork, passwordInput.text); root.pendingNetwork = null; passwordInput.text = ""; } }
                    }
                }
            }
        }
    }
}
