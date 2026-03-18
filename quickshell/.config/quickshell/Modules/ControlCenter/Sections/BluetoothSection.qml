import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    title: "Bluetooth"
    icon: Services.BluetoothService.enabled ? Core.Icons.bluetooth : Core.Icons.bluetooth_off
    rightText: Services.BluetoothService.connectedCount > 0
        ? Services.BluetoothService.connectedCount + " connected" : ""
    expanded: false

    // Adapter toggle
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 8

        Text {
            text: "Bluetooth"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Rectangle {
            width: 40
            height: 20
            radius: 10
            color: Services.BluetoothService.enabled ? Core.Colors.accent : Core.Colors.surface1

            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

            Rectangle {
                x: Services.BluetoothService.enabled ? parent.width - width - 2 : 2
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 8
                color: Core.Colors.text

                Behavior on x {
                    NumberAnimation { duration: Core.Animations.durationFast }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.BluetoothService.enabled = !Services.BluetoothService.enabled
            }
        }
    }

    // Device list
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: btColumn.implicitHeight
        visible: Services.BluetoothService.enabled

        ColumnLayout {
            id: btColumn
            width: parent.width
            spacing: 2

            Repeater {
                model: Services.BluetoothService.devices

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 32
                    radius: 8
                    color: btArea.containsMouse ? Core.Colors.surface1 : "transparent"
                    visible: modelData.paired || modelData.connected

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: Core.Icons.bluetooth
                            color: modelData.connected ? Core.Colors.accent : Core.Colors.overlay0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }

                        Text {
                            text: modelData.name || modelData.deviceName || modelData.address
                            color: Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Battery percentage
                        Text {
                            visible: modelData.batteryAvailable
                            text: Math.round(modelData.battery) + "%"
                            color: Core.Colors.overlay0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }

                        // State badge
                        Rectangle {
                            visible: modelData.connected
                            width: btStateLabel.implicitWidth + 10
                            height: 18
                            radius: 9
                            color: Core.Colors.accent
                            opacity: 0.2

                            Text {
                                id: btStateLabel
                                anchors.centerIn: parent
                                text: "Connected"
                                color: Core.Colors.accent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                            }
                        }
                    }

                    MouseArea {
                        id: btArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.connected) modelData.disconnect()
                            else modelData.connect()
                        }
                    }
                }
            }

            // Empty state
            Text {
                visible: {
                    if (!Services.BluetoothService.devices) return true
                    for (let i = 0; i < Services.BluetoothService.devices.values.length; i++) {
                        let d = Services.BluetoothService.devices.values[i]
                        if (d.paired || d.connected) return false
                    }
                    return true
                }
                text: "No paired devices"
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
            }
        }
    }
}
