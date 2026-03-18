import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../Core" as Core

RowLayout {
    spacing: 8

    Text {
        text: Core.Icons.arch
        font.pixelSize: 18
        font.family: "Symbols Nerd Font"
        color: Core.Colors.accent

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch("exec [float;size 1000 600;center] ghostty -e bash -c 'printf \"\\033[?25l\"; fastfetch; sleep infinity'")
        }
    }

    Repeater {
        model: 9

        Rectangle {
            id: wsButton
            required property int index
            property int wsId: index + 1
            property bool active: Hyprland.focusedMonitor?.activeWorkspace?.id === wsId
            property bool occupied: {
                for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                    if (Hyprland.workspaces.values[i].id === wsId) return true
                }
                return false
            }

            width: active ? 28 : 12
            height: 12
            radius: 6
            color: Core.Colors.accent
            opacity: active ? 1.0 : 0.2

            Behavior on width {
                NumberAnimation {
                    duration: Core.Animations.durationFast
                    easing.type: Core.Animations.easingType
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Core.Animations.durationFast
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Core.Animations.durationFast
                    easing.type: Core.Animations.easingType
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + wsId)
            }
        }
    }
}
