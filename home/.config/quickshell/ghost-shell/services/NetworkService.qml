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

    readonly property bool scanning:
        wifiDevice?.scannerEnabled ?? false

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

    readonly property string activeInterface: activeDevice?.name ?? ""

    // The first saved profile for an SSID need not be the active profile.
    property string activeUuid: ""
    property string lastConnectionError: ""
    readonly property bool dnsBusy: dnsModifyProcess.running || reapplyCheckProcess.running || reapplyProcess.running
    property string dnsInterface: ""
    property string dnsUuid: ""
    property bool detailsPending: false
    property int detailsRevision: 0

    onActiveInterfaceChanged: invalidateDetails()
    onActiveNetworkChanged: invalidateDetails()

    function invalidateDetails() {
        detailsRevision++;
        activeUuid = "";
        ipv4Address = "";
        ipv4Gateway = "";
        ipv4Dns = "";
        refreshDetails();
    }

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
        if (!wifiDevice || disconnectProcess.running)
            return;

        lastConnectionError = "";
        disconnectProcess.exec([
            "nmcli",
            "device",
            "disconnect",
            wifiDevice.name
        ]);
    }

    function refreshDetails() {
        if (detailsProcess.running) {
            detailsPending = true;
            return;
        }
        detailsPending = false;
        if (!activeInterface)
            return;
        detailsProcess.requestInterface = activeInterface;
        detailsProcess.requestRevision = detailsRevision;
        detailsProcess.exec([
            "nmcli", "--terse", "--escape", "no",
            "--fields", "GENERAL.CON-UUID,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS",
            "device", "show", activeInterface
        ]);
    }

    function applyDns(mode, customValue) {
        if (dnsBusy)
            return;
        if (!activeUuid || !activeInterface || detailsProcess.running) {
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

        dnsInterface = activeInterface;
        dnsUuid = activeUuid;
        dnsStatus = "Applying…";
        lastDnsError = "";

        dnsModifyProcess.exec([
            "nmcli",
            "connection",
            "modify",
            "uuid",
            dnsUuid,

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
        onExited: exitCode => {
            if (exitCode !== 0)
                root.lastConnectionError = "Wi-Fi disconnect failed";
            root.refreshDetails();
        }
    }

    Process {
        id: detailsProcess
        property string requestInterface: ""
        property int requestRevision: 0
        stdout: StdioCollector { id: detailsOutput }
        onExited: exitCode => {
            if (requestInterface === root.activeInterface && requestRevision === root.detailsRevision) {
                root.activeUuid = "";
                root.ipv4Address = "";
                root.ipv4Gateway = "";
                root.ipv4Dns = "";
                if (exitCode === 0) {
                    const addresses = [];
                    const dns = [];
                    for (const line of detailsOutput.text.trim().split("\n")) {
                        const separator = line.indexOf(":");
                        if (separator < 0)
                            continue;
                        const key = line.slice(0, separator).replace(/\[\d+\]$/, "");
                        const value = line.slice(separator + 1);
                        if (key === "GENERAL.CON-UUID")
                            root.activeUuid = value === "--" ? "" : value;
                        else if (key === "IP4.ADDRESS" && value)
                            addresses.push(value);
                        else if (key === "IP4.GATEWAY")
                            root.ipv4Gateway = value;
                        else if (key === "IP4.DNS" && value)
                            dns.push(value);
                    }
                    root.ipv4Address = addresses.join("  ");
                    root.ipv4Dns = dns.join("  ");
                }
            }
            if (root.detailsPending)
                Qt.callLater(root.refreshDetails);
        }
    }

    Process {
        id: dnsModifyProcess

        stderr: StdioCollector {
            onStreamFinished:
                root.lastDnsError = this.text.trim()
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.dnsStatus =
                    root.lastDnsError.length > 0
                        ? root.lastDnsError
                        : "DNS change failed";

                return;
            }

            reapplyCheckProcess.exec([
                "nmcli", "-g", "GENERAL.CON-UUID", "device", "show", root.dnsInterface
            ]);
        }
    }

    Process {
        id: reapplyCheckProcess
        stdout: StdioCollector { id: reapplyConnection }
        onExited: exitCode => {
            if (exitCode !== 0 || reapplyConnection.text.trim() !== root.dnsUuid) {
                root.dnsStatus = "Saved; connection changed before reapply";
                root.refreshDetails();
                return;
            }
            reapplyProcess.exec(["nmcli", "device", "reapply", root.dnsInterface]);
        }
    }

    Process {
        id: reapplyProcess

        onExited: exitCode => {
            if (exitCode === 0)
                root.dnsStatus = "DNS applied";
            else
                root.dnsStatus =
                    "Saved; reconnect to apply";

            root.refreshDetails();
        }
    }
}
