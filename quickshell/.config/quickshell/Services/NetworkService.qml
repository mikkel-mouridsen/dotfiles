pragma Singleton
import QtQuick
import Quickshell.Networking

QtObject {
    readonly property bool wifiEnabled: Networking.wifiEnabled

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled
    }

    readonly property var wifiDevice: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            let dev = Networking.devices.values[i]
            if (dev.type === DeviceType.Wifi) return dev
        }
        return null
    }

    readonly property bool connected: wifiDevice?.connected ?? false
    readonly property var networks: wifiDevice?.networks ?? null

    readonly property string currentNetwork: {
        if (!networks) return ""
        for (let i = 0; i < networks.values.length; i++) {
            let net = networks.values[i]
            if (net.connected) return net.name
        }
        return ""
    }

    property bool scannerEnabled: false

    onScannerEnabledChanged: {
        if (wifiDevice) wifiDevice.scannerEnabled = scannerEnabled
    }
}
