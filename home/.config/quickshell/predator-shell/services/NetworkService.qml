pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    readonly property var devices: Networking.devices.values

    readonly property var wifiDevice: {
        for (const device of devices) {
            if (device.type === DeviceType.Wifi)
                return device;
        }

        return null;
    }

    readonly property var wiredDevice: {
        for (const device of devices) {
            if (device.type === DeviceType.Wired)
                return device;
        }

        return null;
    }

    readonly property bool wifiEnabled:
        Networking.wifiEnabled

    readonly property bool wifiHardwareEnabled:
        Networking.wifiHardwareEnabled

    readonly property bool wiredConnected:
        wiredDevice?.connected ?? false

    readonly property bool wifiConnected:
        wifiDevice?.connected ?? false

    readonly property var wifiNetworks:
        wifiDevice?.networks?.values ?? []

    readonly property var connectedWifi: {
        for (const network of wifiNetworks) {
            if (network.connected)
                return network;
        }

        return null;
    }

    readonly property string ssid:
        connectedWifi?.name ?? ""

    readonly property real signalStrength:
        connectedWifi?.signalStrength ?? 0

    readonly property bool connected:
        wiredConnected || wifiConnected

    // Prefer Ethernet when both are active.
    readonly property var activeDevice:
        wiredConnected
            ? wiredDevice
            : wifiConnected
                ? wifiDevice
                : null

    readonly property var activeNetwork:
        wiredConnected
            ? wiredDevice?.network
            : wifiConnected
                ? connectedWifi
                : null

    readonly property var activeSettings:
        activeNetwork
        && activeNetwork.nmSettings
        && activeNetwork.nmSettings.length > 0
            ? activeNetwork.nmSettings[0]
            : null

    readonly property string activeInterface:
        activeDevice?.name ?? ""

    readonly property string activeUuid:
        activeSettings?.uuid ?? ""

    property string ipv4Address: ""
    property string ipv4Gateway: ""
    property string ipv4Dns: ""

    property string dnsStatus: ""
    property string lastDnsError: ""

    function setWifiEnabled(enabled) {
        if (wifiHardwareEnabled)
            Networking.wifiEnabled = enabled;
    }

    function startScanning() {
        if (wifiDevice)
            wifiDevice.scannerEnabled = true;
    }

    function stopScanning() {
        if (wifiDevice)
            wifiDevice.scannerEnabled = false;
    }

    function connectNetwork(network) {
        if (network)
            network.connect();
    }

    function connectWithPassword(network, password) {
        if (!network || password.length === 0)
            return;

        network.connectWithPsk(password);
    }

    function disconnectWifi() {
        if (!wifiDevice)
            return;

        disconnectProcess.exec([
            "nmcli",
            "device",
            "disconnect",
            wifiDevice.name
        ]);
    }

    function refreshDetails() {
        if (!activeInterface) {
            ipv4Address = "";
            ipv4Gateway = "";
            ipv4Dns = "";
            return;
        }

        addressProcess.exec([
            "nmcli",
            "-g",
            "IP4.ADDRESS",
            "device",
            "show",
            activeInterface
        ]);

        gatewayProcess.exec([
            "nmcli",
            "-g",
            "IP4.GATEWAY",
            "device",
            "show",
            activeInterface
        ]);

        dnsReadProcess.exec([
            "nmcli",
            "-g",
            "IP4.DNS",
            "device",
            "show",
            activeInterface
        ]);
    }

    function applyDns(mode, customValue) {
        if (!activeUuid || !activeInterface) {
            dnsStatus = "No active connection";
            return;
        }

        let ipv4 = "";
        let ipv6 = "";
        let custom4 = false;
        let custom6 = false;

        switch (mode) {
        case "cloudflare":
            ipv4 = "1.1.1.1 1.0.0.1";
            ipv6 = "2606:4700:4700::1111 2606:4700:4700::1001";
            custom4 = true;
            custom6 = true;
            break;

        case "google":
            ipv4 = "8.8.8.8 8.8.4.4";
            ipv6 = "2001:4860:4860::8888 2001:4860:4860::8844";
            custom4 = true;
            custom6 = true;
            break;

        case "quad9":
            ipv4 = "9.9.9.9 149.112.112.112";
            ipv6 = "2620:fe::fe 2620:fe::9";
            custom4 = true;
            custom6 = true;
            break;

        case "custom": {
            const entries = customValue
                .replace(/,/g, " ")
                .trim()
                .split(/\s+/)
                .filter(value => value.length > 0);

            const ipv4Entries =
                entries.filter(value => !value.includes(":"));

            const ipv6Entries =
                entries.filter(value => value.includes(":"));

            if (entries.length === 0) {
                dnsStatus = "Enter at least one DNS server";
                return;
            }

            ipv4 = ipv4Entries.join(" ");
            ipv6 = ipv6Entries.join(" ");

            custom4 = ipv4Entries.length > 0;
            custom6 = ipv6Entries.length > 0;
            break;
        }

        case "automatic":
        default:
            break;
        }

        dnsStatus = "Applying…";
        lastDnsError = "";

        dnsModifyProcess.exec([
            "nmcli",
            "connection",
            "modify",
            "uuid",
            activeUuid,

            "ipv4.ignore-auto-dns",
            custom4 ? "yes" : "no",

            "ipv4.dns",
            ipv4,

            "ipv6.ignore-auto-dns",
            custom6 ? "yes" : "no",

            "ipv6.dns",
            ipv6
        ]);
    }

    Process {
        id: disconnectProcess
    }

    Process {
        id: addressProcess

        stdout: StdioCollector {
            onStreamFinished:
                root.ipv4Address = this.text.trim()
        }
    }

    Process {
        id: gatewayProcess

        stdout: StdioCollector {
            onStreamFinished:
                root.ipv4Gateway = this.text.trim()
        }
    }

    Process {
        id: dnsReadProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.ipv4Dns = this.text
                    .trim()
                    .split("\n")
                    .filter(value => value.length > 0)
                    .join("  ");
            }
        }
    }

    Process {
        id: dnsModifyProcess

        stderr: StdioCollector {
            onStreamFinished:
                root.lastDnsError = this.text.trim()
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.dnsStatus =
                    root.lastDnsError.length > 0
                        ? root.lastDnsError
                        : "DNS change failed";

                return;
            }

            reapplyProcess.exec([
                "nmcli",
                "device",
                "reapply",
                root.activeInterface
            ]);
        }
    }

    Process {
        id: reapplyProcess

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.dnsStatus = "DNS applied";
            else
                root.dnsStatus =
                    "Saved; reconnect to apply";

            root.refreshDetails();
        }
    }
}
