import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    id: root
    title: "Tailscale"
    icon: Services.TailscaleService.running ? Core.Icons.vpn : Core.Icons.vpn_off
    rightText: Services.TailscaleService.running ? Services.TailscaleService.currentIP : ""
    actionIcon: Core.Icons.terminal
    onActionClicked: {
        Hyprland.dispatch("exec [float;size 900 600;center] ghostty -e tsui")
        Core.State.controlCenterOpen = false
    }
    expanded: false

    // Enable polling only when expanded and control center is open
    onExpandedChanged: {
        Services.TailscaleService.pollingEnabled = expanded && Core.State.controlCenterOpen
    }

    Connections {
        target: Core.State
        function onControlCenterOpenChanged() {
            Services.TailscaleService.pollingEnabled = root.expanded && Core.State.controlCenterOpen
        }
    }

    // VPN toggle
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 8

        Text {
            text: "Tailscale"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Rectangle {
            width: 40
            height: 20
            radius: 10
            color: Services.TailscaleService.running ? Core.Colors.accent : Core.Colors.surface1

            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

            Rectangle {
                x: Services.TailscaleService.running ? parent.width - width - 2 : 2
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
                onClicked: Services.TailscaleService.toggleUp()
            }
        }
    }

    // Info + peer list (visible when connected)
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: tsColumn.implicitHeight
        visible: Services.TailscaleService.running

        ColumnLayout {
            id: tsColumn
            width: parent.width
            spacing: 2

            // Hostname + IP info row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: Services.TailscaleService.hostname
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: Services.TailscaleService.currentIP
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
            }

            // Exit node badge
            Rectangle {
                visible: Services.TailscaleService.exitNode !== ""
                width: exitLabel.implicitWidth + 14
                height: 20
                radius: 10
                color: Core.Colors.accent
                opacity: 0.2
                Layout.topMargin: 2

                Text {
                    id: exitLabel
                    anchors.centerIn: parent
                    text: "Exit: " + Services.TailscaleService.exitNode
                    color: Core.Colors.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                }
            }

            // Peer list
            Repeater {
                model: Services.TailscaleService.peers

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 32
                    radius: 8
                    color: peerArea.containsMouse ? Core.Colors.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: Core.Icons.vpn
                            color: modelData.online ? Core.Colors.green : Core.Colors.overlay0
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

                        Text {
                            text: modelData.os
                            color: Core.Colors.overlay0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }

                        Rectangle {
                            width: statusLabel.implicitWidth + 10
                            height: 18
                            radius: 9
                            color: modelData.online ? Core.Colors.accent : Core.Colors.surface1
                            opacity: modelData.online ? 0.2 : 1.0

                            Text {
                                id: statusLabel
                                anchors.centerIn: parent
                                text: modelData.online ? "Online" : "Offline"
                                color: modelData.online ? Core.Colors.accent : Core.Colors.overlay0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                            }
                        }
                    }

                    MouseArea {
                        id: peerArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }

            // Empty state
            Text {
                visible: Services.TailscaleService.peers.length === 0
                text: "No peers found"
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
            }
        }
    }
}
