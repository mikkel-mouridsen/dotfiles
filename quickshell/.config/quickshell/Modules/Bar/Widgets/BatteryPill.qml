import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../Core" as Core

Rectangle {
    id: batteryPill
    color: Core.Colors.surface0
    radius: 10
    width: batteryRow.implicitWidth + 16
    height: 28
    visible: batteryPercent >= 0

    property int batteryPercent: -1
    property bool charging: false

    // Poll battery status
    Process {
        id: batteryProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true

        stdout: SplitParser {
            onRead: data => batteryPercent = parseInt(data) || -1
        }
    }

    Process {
        id: chargeProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true

        stdout: SplitParser {
            onRead: data => charging = data.trim() === "Charging"
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            batteryProc.running = true
            chargeProc.running = true
        }
    }

    RowLayout {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: Core.Icons.batteryIcon(batteryPercent, charging)
            color: batteryPercent <= 15 ? Core.Colors.red
                : batteryPercent <= 30 ? Core.Colors.yellow
                : charging ? Core.Colors.green
                : Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }

        Text {
            text: batteryPercent + "%"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }
    }
}
