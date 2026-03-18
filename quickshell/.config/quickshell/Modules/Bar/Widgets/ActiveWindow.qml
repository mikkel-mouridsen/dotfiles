import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../Core" as Core

Item {
    property var activeWindow: Hyprland.focusedClient

    Layout.maximumWidth: 300
    Layout.fillHeight: true
    implicitWidth: label.implicitWidth

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 300)
        text: activeWindow?.title ?? ""
        color: Core.Colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        elide: Text.ElideRight
        maximumLineCount: 1
    }
}
