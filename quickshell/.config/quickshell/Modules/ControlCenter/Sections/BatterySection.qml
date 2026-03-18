import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    title: "Battery"
    icon: Core.Icons.batteryIcon(Services.BatteryService.percentage, Services.BatteryService.charging)
    rightText: Services.BatteryService.available ? Services.BatteryService.percentage + "%" : ""
    expanded: true
    visible: Services.BatteryService.available

    // Battery status
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 10

        Text {
            text: Core.Icons.batteryIcon(Services.BatteryService.percentage, Services.BatteryService.charging)
            color: Services.BatteryService.percentage <= 15 ? Core.Colors.red
                : Services.BatteryService.percentage <= 30 ? Core.Colors.yellow
                : Services.BatteryService.charging ? Core.Colors.green
                : Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
        }

        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Text {
                text: Services.BatteryService.percentage + "% — " + Services.BatteryService.stateText
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }

            Text {
                text: Services.BatteryService.timeRemaining
                    ? Services.BatteryService.timeRemaining + " remaining" : ""
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                visible: text !== ""
            }
        }
    }

    // Power profile selector
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: profileColumn.implicitHeight

        ColumnLayout {
            id: profileColumn
            width: parent.width
            spacing: 6

            Text {
                text: "Power Profile"
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            // 3-segment selector
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 10
                color: Core.Colors.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3

                    Repeater {
                        model: [
                            { label: "Power Saver", icon: Core.Icons.profile_powersaver, profile: PowerProfile.PowerSaver },
                            { label: "Balanced", icon: Core.Icons.profile_balanced, profile: PowerProfile.Balanced },
                            { label: "Performance", icon: Core.Icons.profile_performance, profile: PowerProfile.Performance }
                        ]

                        Rectangle {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: Services.BatteryService.powerProfile === modelData.profile
                                ? Core.Colors.accent : "transparent"
                            visible: index !== 2 || Services.BatteryService.hasPerformanceProfile

                            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: modelData.icon
                                    color: Services.BatteryService.powerProfile === modelData.profile
                                        ? Core.Colors.crust : Core.Colors.subtext0
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: modelData.label
                                    color: Services.BatteryService.powerProfile === modelData.profile
                                        ? Core.Colors.crust : Core.Colors.subtext0
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Services.BatteryService.setPowerProfile(modelData.profile)
                            }
                        }
                    }
                }
            }
        }
    }
}
