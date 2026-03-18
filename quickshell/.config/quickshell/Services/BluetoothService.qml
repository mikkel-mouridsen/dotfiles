pragma Singleton
import QtQuick
import Quickshell.Bluetooth

QtObject {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null

    property bool enabled: adapter?.enabled ?? false
    onEnabledChanged: {
        if (adapter && adapter.enabled !== enabled)
            adapter.enabled = enabled
    }

    property bool discovering: adapter?.discovering ?? false
    onDiscoveringChanged: {
        if (adapter && adapter.discovering !== discovering)
            adapter.discovering = discovering
    }

    readonly property var devices: Bluetooth.devices

    readonly property int connectedCount: {
        let count = 0
        if (!devices) return 0
        for (let i = 0; i < devices.values.length; i++) {
            if (devices.values[i].connected) count++
        }
        return count
    }
}
