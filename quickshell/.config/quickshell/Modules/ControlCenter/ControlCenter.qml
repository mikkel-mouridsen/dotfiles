import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Core" as Core
import "Sections" as Sections

PanelWindow {
    id: popup

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "controlcenter"

    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: Math.min(contentFlickable.contentHeight + 60, 800)

    margins.top: 56

    visible: Core.State.controlCenterOpen
    color: "transparent"

    mask: Region { item: panel }

    function close() { Core.State.controlCenterOpen = false }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }

    Rectangle {
        id: panel
        width: 380
        anchors.right: parent.right
        anchors.rightMargin: 28
        anchors.top: parent.top
        height: Math.min(contentFlickable.contentHeight + 60, popup.height - 20)
        color: Core.Colors.mantle
        radius: 16
        border.width: 1
        border.color: Core.Colors.glassBorder

        // Header
        RowLayout {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            anchors.bottomMargin: 0
            height: 28
            spacing: 8

            Text {
                text: "Control Center"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            Text {
                text: Core.Icons.close
                color: closeArea.containsMouse ? Core.Colors.text : Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13

                Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.close()
                }
            }
        }

        // Scrollable content
        Flickable {
            id: contentFlickable
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 16
            anchors.topMargin: 8
            contentHeight: contentColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 12

                Sections.QuickToggles {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Sections.AudioSection {
                    Layout.fillWidth: true
                }

                Sections.BatterySection {
                    Layout.fillWidth: true
                }

                Sections.NetworkSection {
                    Layout.fillWidth: true
                }

                Sections.BluetoothSection {
                    Layout.fillWidth: true
                }

                Sections.NotificationsSection {
                    Layout.fillWidth: true
                }

                // Bottom padding
                Item { Layout.preferredHeight: 4 }
            }
        }
    }
}
