pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // UPower's aggregate device is intended for desktop display.
    readonly property var battery: UPower.displayDevice

    readonly property bool ready:
        battery?.ready ?? false

    readonly property bool onBattery:
        UPower.onBattery

    // Quickshell represents percentage internally as 0.0–1.0.
    readonly property real percentage:
        ready ? battery.percentage * 100 : 0

    readonly property bool charging:
        ready
        && battery.state === UPowerDeviceState.Charging

    readonly property bool discharging:
        ready
        && battery.state === UPowerDeviceState.Discharging

    readonly property bool fullyCharged:
        ready
        && battery.state === UPowerDeviceState.FullyCharged

    readonly property real timeRemaining: {
        if (!ready)
            return 0;

        if (charging)
            return battery.timeToFull;

        if (discharging)
            return battery.timeToEmpty;

        return 0;
    }

    readonly property bool healthAvailable:
        ready && battery.healthSupported

    readonly property real health:
        healthAvailable
            ? battery.healthPercentage
            : 0

    readonly property real energy:
        ready ? battery.energy : 0

    readonly property real capacity:
        ready ? battery.energyCapacity : 0

    readonly property real powerRate:
        ready ? Math.abs(battery.changeRate) : 0

    readonly property int profile:
        PowerProfiles.profile

    readonly property bool performanceAvailable:
        PowerProfiles.hasPerformanceProfile

    readonly property string profileName: {
        switch (profile) {
        case PowerProfile.Performance:
            return "Performance";

        case PowerProfile.PowerSaver:
            return "Power Saver";

        case PowerProfile.Balanced:
        default:
            return "Balanced";
        }
    }

    readonly property string statusText: {
        if (!ready)
            return "Unknown";

        if (fullyCharged)
            return "Fully charged";

        if (charging)
            return "Charging";

        if (discharging)
            return "Discharging";

        return "Idle";
    }

    readonly property string rateText: {
        if (!ready)
            return "—";

        if (powerRate < 0.05)
            return "0.0 W";

        if (charging)
            return powerRate.toFixed(1) + " W charging";

        if (discharging)
            return powerRate.toFixed(1) + " W draw";

        return powerRate.toFixed(1) + " W";
    }

    function setProfile(profile) {
        if (profile === PowerProfile.Performance
                && !performanceAvailable)
            return;

        PowerProfiles.profile = profile;
    }

    function formatDuration(seconds) {
        if (!seconds || seconds <= 0)
            return "—";

        const totalMinutes =
            Math.round(seconds / 60);

        const hours =
            Math.floor(totalMinutes / 60);

        const minutes =
            totalMinutes % 60;

        if (hours === 0)
            return minutes + " min";

        return hours + "h "
            + minutes.toString().padStart(2, "0")
            + "m";
    }
}
