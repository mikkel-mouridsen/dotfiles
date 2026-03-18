import QtQuick
import QtQuick.Layouts
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    id: root
    title: "Network"
    icon: Services.NetworkService.wifiEnabled ? Core.Icons.wifi : Core.Icons.wifi_off
    rightText: Services.NetworkService.currentNetwork
    expanded: false

    // Enable scanning only when expanded and control center is open
    onExpandedChanged: {
        Services.NetworkService.scannerEnabled = expanded && Core.State.controlCenterOpen
    }

    Connections {
        target: Core.State
        function onControlCenterOpenChanged() {
            Services.NetworkService.scannerEnabled = root.expanded && Core.State.controlCenterOpen
        }
    }

    // WiFi toggle
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 8

        Text {
            text: "Wi-Fi"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Rectangle {
            width: 40
            height: 20
            radius: 10
            color: Services.NetworkService.wifiEnabled ? Core.Colors.accent : Core.Colors.surface1

            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

            Rectangle {
                x: Services.NetworkService.wifiEnabled ? parent.width - width - 2 : 2
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
                onClicked: Services.NetworkService.setWifiEnabled(!Services.NetworkService.wifiEnabled)
            }
        }
    }

    // Network list
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: netColumn.implicitHeight
        visible: Services.NetworkService.wifiEnabled

        ColumnLayout {
            id: netColumn
            width: parent.width
            spacing: 2

            Repeater {
                model: Services.NetworkService.networks

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 32
                    radius: 8
                    color: netArea.containsMouse ? Core.Colors.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: Core.Icons.signal_full
                            color: Core.Colors.overlay0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }

                        Text {
                            text: modelData.name
                            color: Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            visible: modelData.connected
                            width: connLabel.implicitWidth + 10
                            height: 18
                            radius: 9
                            color: Core.Colors.accent
                            opacity: 0.2

                            Text {
                                id: connLabel
                                anchors.centerIn: parent
                                text: "Connected"
                                color: Core.Colors.accent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                            }
                        }

                        Rectangle {
                            visible: !modelData.connected && modelData.known
                            width: knownLabel.implicitWidth + 10
                            height: 18
                            radius: 9
                            color: Core.Colors.surface1

                            Text {
                                id: knownLabel
                                anchors.centerIn: parent
                                text: "Known"
                                color: Core.Colors.overlay0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                            }
                        }
                    }

                    MouseArea {
                        id: netArea
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
        }
    }
}
