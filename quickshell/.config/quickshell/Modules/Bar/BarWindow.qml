import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../Core" as Core
import "Widgets" as Widgets

PanelWindow {
    id: barWindow

    property var targetScreen: null
    screen: targetScreen

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "bar"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 8
        left: 28
        right: 28
    }

    implicitHeight: 40
    color: "transparent"
    exclusiveZone: 28  // tuned so bar-to-window gap = gaps_in (8)
    exclusionMode: ExclusionMode.Normal

    Rectangle {
        anchors.fill: parent
        color: Core.Colors.glass
        radius: 14
        border.width: 1
        border.color: Core.Colors.glassBorder

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            // Left section
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                spacing: 6

                Widgets.Workspaces {}
                Widgets.ActiveWindow {}
            }

            // Center section
            Item { Layout.fillWidth: true }

            Widgets.MusicPlayer {}

            Item { Layout.fillWidth: true }

            // Right section
            Row {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Widgets.SystemTray {}
                Widgets.StatusPill {}
                Widgets.PowerButton {}
            }
        }
    }
}
