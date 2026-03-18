import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../Core" as Core
import "../../../Services" as Services

Rectangle {
    id: statusPill
    color: pillArea.containsMouse ? Core.Colors.surface1 : Core.Colors.surface0
    radius: 10
    width: statusRow.implicitWidth + 16
    height: 28

    Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

    RowLayout {
        id: statusRow
        anchors.centerIn: parent
        spacing: 8

        // Clock
        Text {
            id: clockText
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13

            text: Qt.formatTime(new Date(), "hh:mm")

            Timer {
                interval: 30000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
            }
        }

        // Separator
        Rectangle {
            width: 1
            height: 14
            color: Core.Colors.overlay0
            opacity: 0.4
        }

        // WiFi icon
        Text {
            text: Services.NetworkService.wifiEnabled ? Core.Icons.wifi : Core.Icons.wifi_off
            color: Services.NetworkService.connected ? Core.Colors.accent : Core.Colors.overlay0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }

        // Volume icon
        Text {
            text: Core.Icons.volumeIcon(Services.VolumeService.volume, Services.VolumeService.muted)
            color: Services.VolumeService.muted ? Core.Colors.overlay0 : Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }

        // Battery (only shown if available)
        RowLayout {
            spacing: 4
            visible: Services.BatteryService.available

            Text {
                text: Core.Icons.batteryIcon(Services.BatteryService.percentage, Services.BatteryService.charging)
                color: Services.BatteryService.percentage <= 15 ? Core.Colors.red
                    : Services.BatteryService.percentage <= 30 ? Core.Colors.yellow
                    : Services.BatteryService.charging ? Core.Colors.green
                    : Core.Colors.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }

            Text {
                text: Services.BatteryService.percentage + "%"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }
        }
    }

    MouseArea {
        id: pillArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Core.State.toggleControlCenter()
        onWheel: function(event) {
            let delta = event.angleDelta.y > 0 ? 5 : -5
            Services.VolumeService.adjustVolume(delta)
        }
    }
}
