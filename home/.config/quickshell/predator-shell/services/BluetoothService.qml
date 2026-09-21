pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property var devices:
        Bluetooth.devices?.values ?? []

    readonly property var connectedDevices:
        devices.filter(device => device.connected)

    readonly property int connectedCount:
        connectedDevices.length

    function setEnabled(value) {
        if (adapter)
            adapter.enabled = value;
    }

    function startDiscovery() {
        if (adapter && adapter.enabled)
            adapter.discovering = true;
    }

    function stopDiscovery() {
        if (adapter)
            adapter.discovering = false;
    }

    function toggleDiscovery() {
        if (!adapter)
            return;

        adapter.discovering = !adapter.discovering;
    }

    function connectDevice(device) {
        if (device)
            device.connect();
    }

    function disconnectDevice(device) {
        if (device)
            device.disconnect();
    }

    function pairDevice(device) {
        if (device)
            device.pair();
    }

    function cancelPair(device) {
        if (device?.pairing)
            device.cancelPair();
    }

    function forgetDevice(device) {
        if (device)
            device.forget();
    }
}
