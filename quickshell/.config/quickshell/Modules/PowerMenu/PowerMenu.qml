import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../Core" as Core

PanelWindow {
    id: powerMenu

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "power-menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: Core.State.powerMenuOpen
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: Core.State.powerMenuOpen = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: actionsRow.implicitWidth + 60
        height: 180
        color: Core.Colors.glass
        radius: 20
        border.width: 1
        border.color: Core.Colors.glassBorder

        MouseArea { anchors.fill: parent }

        RowLayout {
            id: actionsRow
            anchors.centerIn: parent
            spacing: 24

            Repeater {
                model: [
                    { icon: Core.Icons.lock, label: "Lock", cmd: "hyprlock" },
                    { icon: Core.Icons.suspend, label: "Suspend", cmd: "systemctl suspend" },
                    { icon: Core.Icons.reboot, label: "Reboot", cmd: "systemctl reboot" },
                    { icon: Core.Icons.shutdown, label: "Shutdown", cmd: "systemctl poweroff" },
                    { icon: Core.Icons.logout, label: "Logout", cmd: "hyprctl dispatch exit" },
                ]

                Rectangle {
                    required property var modelData
                    width: 90
                    height: 100
                    radius: 14
                    color: actionArea.containsMouse ? Core.Colors.surface1 : Core.Colors.surface0

                    Behavior on color {
                        ColorAnimation { duration: Core.Animations.durationFast }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: modelData.icon
                            color: actionArea.containsMouse ? Core.Colors.accent : Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: modelData.label
                            color: Core.Colors.subtext0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: actionArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Core.State.powerMenuOpen = false
                            actionProc.command = ["sh", "-c", modelData.cmd]
                            actionProc.running = true
                        }
                    }
                }
            }
        }
    }

    Process {
        id: actionProc
    }

    Shortcut {
        sequence: "Escape"
        onActivated: Core.State.powerMenuOpen = false
    }
}
