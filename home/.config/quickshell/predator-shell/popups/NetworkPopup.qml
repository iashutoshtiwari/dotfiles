import QtQuick
import Quickshell
import Quickshell.Networking

import qs.theme
import qs.services

PopupWindow {
    id: root

    property Item anchorItem

    property string page: "network"
    property var pendingNetwork: null
    property string connectionMessage: ""

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

    implicitWidth: 392
    implicitHeight: 480

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

    function chooseNetwork(network) {
        connectionMessage = "";
        pendingNetwork = null;
        passwordInput.text = "";
        if (!network)
            return;

        if (network.connected)
            return;

        if (network.known) {
            NetworkService.connectNetwork(network);
            return;
        }

        if (network.security === WifiSecurityType.Open
                || network.security === WifiSecurityType.Owe) {
            NetworkService.connectNetwork(network);
            return;
        }

        if (network.security === WifiSecurityType.WpaPsk
                || network.security === WifiSecurityType.Wpa2Psk
                || network.security === WifiSecurityType.Sae) {
            pendingNetwork = network;
            passwordInput.text = "";
            passwordInput.forceActiveFocus();
            return;
        }

        connectionMessage =
            "This security type needs manual setup for now";
    }

    Connections {
        target: NetworkService
        function onLastConnectionErrorChanged() {
            root.connectionMessage = NetworkService.lastConnectionError;
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.base
        border.width: 1
        border.color: Theme.surface0
        radius: 0

        // NETWORK PAGE
        Item {
            anchors {
                fill: parent
                margins: 16
            }

            visible: root.page === "network"

            Column {
                anchors.fill: parent
                spacing: 11

                Row {
                    width: parent.width
                    height: 24

                    Text {
                        width: parent.width - 80

                        text: "NETWORK"

                        font.family: Theme.shellFont
                        font.pixelSize: 14
                        font.weight: Font.DemiBold

                        color: Theme.text
                    }

                    Text {
                        width: 80

                        horizontalAlignment: Text.AlignRight

                        text: NetworkService.wifiEnabled
                            ? "WI-FI ON"
                            : "WI-FI OFF"

                        font.family: Theme.shellFont
                        font.pixelSize: 10

                        color: NetworkService.wifiEnabled
                            ? Theme.lavender
                            : Theme.overlay1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                NetworkService.setWifiEnabled(
                                    !NetworkService.wifiEnabled
                                )
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surface0
                }

                Text {
                    text: NetworkService.wiredConnected
                        ? "󰈀  Ethernet connected"
                        : "󰈂  Ethernet disconnected"

                    font.family: Theme.shellFont
                    font.pixelSize: 11

                    color: NetworkService.wiredConnected
                        ? Theme.green
                        : Theme.overlay1
                }

                Row {
                    width: parent.width

                    Text {
                        width: parent.width - 110

                        text: NetworkService.ssid.length > 0
                            ? "󰤨  " + NetworkService.ssid
                            : "WI-FI"

                        elide: Text.ElideRight

                        font.family: Theme.shellFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold

                        color: Theme.text
                    }

                    Text {
                        width: 110

                        horizontalAlignment: Text.AlignRight

                        text: NetworkService.wifiConnected
                            ? "DISCONNECT"
                            : "SCAN"

                        font.family: Theme.shellFont
                        font.pixelSize: 9

                        color: Theme.lavender

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (NetworkService.wifiConnected)
                                    NetworkService.disconnectWifi();
                                else
                                    NetworkService.startScanning();
                            }
                        }
                    }
                }

                ListView {
                    id: networkList

                    width: parent.width
                    height: 220

                    clip: true
                    spacing: 2

                    model: ScriptModel {
                        values:
                            NetworkService.wifiNetworks
                            .slice()
                            .sort(
                                (a, b) =>
                                    b.signalStrength
                                    - a.signalStrength
                            )
                    }

                    delegate: Rectangle {
                        id: networkRow

                        required property var modelData

                        width: networkList.width
                        height: 36

                        color: modelData.connected
                            ? Theme.surface0
                            : "transparent"

                        readonly property string wifiIcon: {
                            const strength =
                                modelData.signalStrength;

                            if (strength >= 0.75)
                                return "󰤨";
                            if (strength >= 0.50)
                                return "󰤥";
                            if (strength >= 0.25)
                                return "󰤢";

                            return "󰤟";
                        }

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 8
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: networkRow.wifiIcon

                            font.family: Theme.shellFont
                            font.pixelSize: 14

                            color: modelData.connected
                                ? Theme.lavender
                                : Theme.subtext0
                        }

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 38
                                right: stateText.left
                                rightMargin: 8
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: modelData.name

                            elide: Text.ElideRight

                            font.family: Theme.shellFont
                            font.pixelSize: 11

                            color: modelData.connected
                                ? Theme.lavender
                                : Theme.text
                        }

                        Text {
                            id: stateText

                            anchors {
                                right: parent.right
                                rightMargin: 8
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: modelData.connected
                                ? "CONNECTED"
                                : modelData.known
                                    ? "KNOWN"
                                    : ""

                            font.family: Theme.shellFont
                            font.pixelSize: 9

                            color: Theme.overlay1
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                root.chooseNetwork(
                                    parent.modelData
                                )
                        }

                        Connections {
                            target: modelData

                            function onConnectionFailed(reason) {
                                root.connectionMessage =
                                    "Connection failed";
                            }
                        }
                    }
                }

                Text {
                    visible:
                        root.connectionMessage.length > 0

                    text: root.connectionMessage

                    font.family: Theme.shellFont
                    font.pixelSize: 9

                    color: Theme.red
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surface0
                }

                Grid {
                    width: parent.width

                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 5

                    Text {
                        width: 90
                        text: "INTERFACE"
                        font.family: Theme.shellFont
                        font.pixelSize: 9
                        color: Theme.overlay1
                    }

                    Text {
                        width: 240

                        text:
                            NetworkService.activeInterface
                            || "—"

                        font.family: Theme.shellFont
                        font.pixelSize: 9

                        color: Theme.subtext1
                    }

                    Text {
                        width: 90
                        text: "IPv4"
                        font.family: Theme.shellFont
                        font.pixelSize: 9
                        color: Theme.overlay1
                    }

                    Text {
                        width: 240

                        text:
                            NetworkService.ipv4Address
                            || "—"

                        font.family: Theme.shellFont
                        font.pixelSize: 9

                        color: Theme.subtext1
                    }

                    Text {
                        width: 90
                        text: "GATEWAY"
                        font.family: Theme.shellFont
                        font.pixelSize: 9
                        color: Theme.overlay1
                    }

                    Text {
                        width: 240

                        text:
                            NetworkService.ipv4Gateway
                            || "—"

                        font.family: Theme.shellFont
                        font.pixelSize: 9

                        color: Theme.subtext1
                    }

                    Text {
                        width: 90
                        text: "DNS"
                        font.family: Theme.shellFont
                        font.pixelSize: 9
                        color: Theme.overlay1
                    }

                    Row {
                        width: 240
                        spacing: 8

                        Text {
                            width: 180

                            text:
                                NetworkService.ipv4Dns
                                || "Automatic"

                            elide: Text.ElideRight

                            font.family: Theme.shellFont
                            font.pixelSize: 9

                            color: Theme.subtext1
                        }

                        Text {
                            text: "EDIT"

                            font.family: Theme.shellFont
                            font.pixelSize: 9
                            font.weight: Font.DemiBold

                            color: Theme.lavender

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    root.page = "dns"
                            }
                        }
                    }
                }
            }
        }

        // DNS PAGE
        Item {
            anchors {
                fill: parent
                margins: 16
            }

            visible: root.page === "dns"

            Column {
                anchors.fill: parent
                spacing: 13

                Row {
                    width: parent.width
                    height: 26

                    Text {
                        width: 35

                        text: "←"

                        font.family: Theme.shellFont
                        font.pixelSize: 16

                        color: Theme.lavender

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.page = "network"
                        }
                    }

                    Text {
                        text: "DNS"

                        font.family: Theme.shellFont
                        font.pixelSize: 14
                        font.weight: Font.DemiBold

                        color: Theme.text
                    }
                }

                Text {
                    text:
                        "Connection: "
                        + (NetworkService.ssid.length > 0
                            ? NetworkService.ssid
                            : NetworkService.activeInterface)

                    font.family: Theme.shellFont
                    font.pixelSize: 10

                    color: Theme.overlay1
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surface0
                }

                Repeater {
                    model: [
                        {
                            label: "Automatic",
                            detail: "DHCP / router",
                            value: "automatic"
                        },
                        {
                            label: "Cloudflare",
                            detail: "1.1.1.1",
                            value: "cloudflare"
                        },
                        {
                            label: "Google",
                            detail: "8.8.8.8",
                            value: "google"
                        },
                        {
                            label: "Quad9",
                            detail: "9.9.9.9",
                            value: "quad9"
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        width: parent.width
                        height: 42

                        color: Theme.mantle

                        border.width: 1
                        border.color: Theme.surface0

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: modelData.label

                            font.family: Theme.shellFont
                            font.pixelSize: 11

                            color: Theme.text
                        }

                        Text {
                            anchors {
                                right: parent.right
                                rightMargin: 10
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: modelData.detail

                            font.family: Theme.shellFont
                            font.pixelSize: 9

                            color: Theme.overlay1
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                NetworkService.applyDns(
                                    parent.modelData.value,
                                    ""
                                )
                        }
                    }
                }

                Text {
                    text: "CUSTOM"

                    font.family: Theme.shellFont
                    font.pixelSize: 9
                    font.weight: Font.DemiBold

                    color: Theme.overlay1
                }

                Rectangle {
                    width: parent.width
                    height: 38

                    color: Theme.mantle

                    border.width: 1
                    border.color:
                        customDns.activeFocus
                            ? Theme.lavender
                            : Theme.surface1

                    TextInput {
                        id: customDns

                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }

                        verticalAlignment:
                            TextInput.AlignVCenter

                        clip: true

                        text: ""

                        font.family: Theme.shellFont
                        font.pixelSize: 10

                        color: Theme.text

                        selectionColor: Theme.lavender
                        selectedTextColor: Theme.crust

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            visible:
                                customDns.text.length === 0
                                && !customDns.activeFocus

                            text:
                                "1.1.1.1, 1.0.0.1"

                            font.family: Theme.shellFont
                            font.pixelSize: 10

                            color: Theme.overlay0
                        }

                        Keys.onReturnPressed:
                            NetworkService.applyDns(
                                "custom",
                                text
                            )
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 34

                    color: Theme.surface0

                    Text {
                        anchors.centerIn: parent

                        text: "APPLY CUSTOM DNS"

                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        font.weight: Font.DemiBold

                        color: Theme.lavender
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            NetworkService.applyDns(
                                "custom",
                                customDns.text
                            )
                    }
                }

                Text {
                    width: parent.width
                    wrapMode: Text.Wrap

                    text: NetworkService.dnsStatus

                    font.family: Theme.shellFont
                    font.pixelSize: 9

                    color:
                        NetworkService.dnsStatus
                            === "DNS applied"
                            ? Theme.green
                            : Theme.subtext0
                }
            }
        }

        // PASSWORD OVERLAY
        Rectangle {
            id: passwordPanel

            visible: root.pendingNetwork !== null

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                margins: 16
            }

            height: 135

            color: Theme.mantle

            border.width: 1
            border.color: Theme.lavender

            Column {
                anchors {
                    fill: parent
                    margins: 12
                }

                spacing: 9

                Text {
                    text:
                        "CONNECT TO "
                        + (root.pendingNetwork?.name ?? "")

                    elide: Text.ElideRight

                    width: parent.width

                    font.family: Theme.shellFont
                    font.pixelSize: 10
                    font.weight: Font.DemiBold

                    color: Theme.text
                }

                Rectangle {
                    width: parent.width
                    height: 36

                    color: Theme.base

                    border.width: 1
                    border.color:
                        passwordInput.activeFocus
                            ? Theme.lavender
                            : Theme.surface1

                    TextInput {
                        id: passwordInput

                        anchors {
                            fill: parent
                            leftMargin: 9
                            rightMargin: 9
                        }

                        verticalAlignment:
                            TextInput.AlignVCenter

                        echoMode: TextInput.Password

                        font.family: Theme.shellFont
                        font.pixelSize: 11

                        color: Theme.text

                        selectionColor: Theme.lavender
                        selectedTextColor: Theme.crust

                        Keys.onReturnPressed: {
                            NetworkService.connectWithPassword(
                                root.pendingNetwork,
                                text
                            );

                            root.pendingNetwork = null;
                            text = "";
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 20

                    Text {
                        text: "CANCEL"

                        font.family: Theme.shellFont
                        font.pixelSize: 9

                        color: Theme.overlay1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.pendingNetwork = null;
                                passwordInput.text = "";
                            }
                        }
                    }

                    Text {
                        text: "CONNECT"

                        font.family: Theme.shellFont
                        font.pixelSize: 9
                        font.weight: Font.DemiBold

                        color: Theme.lavender

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                NetworkService
                                    .connectWithPassword(
                                        root.pendingNetwork,
                                        passwordInput.text
                                    );

                                root.pendingNetwork = null;
                                passwordInput.text = "";
                            }
                        }
                    }
                }
            }
        }
    }
}
