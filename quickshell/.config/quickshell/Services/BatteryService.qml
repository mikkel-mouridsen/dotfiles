pragma Singleton
import QtQuick
import Quickshell.Services.UPower

QtObject {
    property var device: UPower.displayDevice

    readonly property int percentage: Math.round(device?.percentage ?? -1)
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
    readonly property bool fullyCharged: device?.state === UPowerDeviceState.FullyCharged
    readonly property bool onBattery: UPower.onBattery
    readonly property bool available: percentage >= 0

    readonly property string stateText: {
        if (!device) return "Unknown"
        switch (device.state) {
            case UPowerDeviceState.Charging: return "Charging"
            case UPowerDeviceState.Discharging: return "On Battery"
            case UPowerDeviceState.FullyCharged: return "Fully Charged"
            case UPowerDeviceState.PendingCharge: return "Pending Charge"
            case UPowerDeviceState.PendingDischarge: return "Pending Discharge"
            case UPowerDeviceState.Empty: return "Empty"
            default: return "Unknown"
        }
    }

    readonly property string timeRemaining: {
        let seconds = charging ? (device?.timeToFull ?? 0) : (device?.timeToEmpty ?? 0)
        if (seconds <= 0) return ""
        let hours = Math.floor(seconds / 3600)
        let minutes = Math.floor((seconds % 3600) / 60)
        if (hours > 0) return hours + "h " + minutes + "m"
        return minutes + "m"
    }

    // Power profile management
    property int powerProfile: PowerProfiles.profile

    function setPowerProfile(profile) {
        PowerProfiles.profile = profile
    }

    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile
}
