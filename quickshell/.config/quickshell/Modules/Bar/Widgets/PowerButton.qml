import QtQuick
import "../../../Core" as Core

Rectangle {
    width: 28
    height: 28
    radius: 8
    color: powerArea.containsMouse ? Core.Colors.surface1 : "transparent"

    Text {
        anchors.centerIn: parent
        text: Core.Icons.power
        color: powerArea.containsMouse ? Core.Colors.red : Core.Colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
    }

    MouseArea {
        id: powerArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Core.State.togglePowerMenu()
    }
}
