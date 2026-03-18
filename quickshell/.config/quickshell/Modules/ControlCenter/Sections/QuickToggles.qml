import QtQuick
import QtQuick.Layouts
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Row {
    spacing: 8

    Components.ToggleTile {
        icon: Services.NetworkService.wifiEnabled ? Core.Icons.wifi : Core.Icons.wifi_off
        label: "Wi-Fi"
        active: Services.NetworkService.wifiEnabled
        onToggled: Services.NetworkService.setWifiEnabled(!Services.NetworkService.wifiEnabled)
        width: (parent.parent?.width ?? 300 - 16) / 3 - 6
    }

    Components.ToggleTile {
        icon: Services.BluetoothService.enabled ? Core.Icons.bluetooth : Core.Icons.bluetooth_off
        label: "Bluetooth"
        active: Services.BluetoothService.enabled
        onToggled: Services.BluetoothService.enabled = !Services.BluetoothService.enabled
        width: (parent.parent?.width ?? 300 - 16) / 3 - 6
    }

    Components.ToggleTile {
        icon: Services.NotificationService.doNotDisturb ? Core.Icons.dnd : Core.Icons.bell
        label: "DND"
        active: Services.NotificationService.doNotDisturb
        onToggled: Services.NotificationService.doNotDisturb = !Services.NotificationService.doNotDisturb
        width: (parent.parent?.width ?? 300 - 16) / 3 - 6
    }
}
