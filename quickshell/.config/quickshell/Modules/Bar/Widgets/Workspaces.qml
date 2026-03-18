import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../Core" as Core

RowLayout {
    spacing: 4

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

            width: active ? 24 : 10
            height: 10
            radius: 5
            color: active ? Core.Colors.accent : occupied ? Core.Colors.surface1 : Core.Colors.surface0

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

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + wsId)
            }
        }
    }
}
