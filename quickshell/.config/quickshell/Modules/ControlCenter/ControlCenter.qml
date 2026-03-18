import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../Core" as Core
import "../../Services" as Services
import "Sections" as Sections

PanelWindow {
    id: popup

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "controlcenter"

    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    anchors.right: true

    property int heroHeight: 100

    implicitHeight: Math.min(contentFlickable.contentHeight + heroHeight + 24, 800)

    margins.top: 56

    visible: Core.State.controlCenterOpen
    color: "transparent"

    mask: Region { item: borderGlow }

    function close() { Core.State.controlCenterOpen = false }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }

    // Gradient border (mauve → lavender)
    Rectangle {
        id: borderGlow
        width: panel.width + 4
        height: panel.height + 4
        anchors.horizontalCenter: panel.horizontalCenter
        anchors.verticalCenter: panel.verticalCenter
        radius: 18
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0.796, 0.651, 0.969, 0.67) }
            GradientStop { position: 1.0; color: Qt.rgba(0.706, 0.745, 0.996, 0.67) }
        }
    }

    Item {
        id: panel
        width: 380
        anchors.right: parent.right
        anchors.rightMargin: 28
        anchors.top: parent.top
        height: Math.min(contentFlickable.contentHeight + heroHeight + 24, popup.height - 20)

        // Rounded mask
        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 16
            visible: false
        }

        // Visual content (rendered offscreen, then masked)
        Item {
            id: visualContent
            anchors.fill: parent
            visible: false

            // Wallpaper hero (top)
            Image {
                width: parent.width
                height: popup.heroHeight
                source: Services.WallpaperService.currentWallpaper
                    ? "file://" + Services.WallpaperService.currentWallpaper : ""
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignVCenter
            }

            // Darken wallpaper + gradient fade
            Rectangle {
                width: parent.width
                height: popup.heroHeight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 0.6; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                }
            }

            // Title on hero
            Text {
                x: 16
                y: 16
                text: "Control Center"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            // Content background
            Rectangle {
                y: popup.heroHeight
                width: parent.width
                height: parent.height - popup.heroHeight
                color: Core.Colors.mantle
            }

            // Separator
            Rectangle {
                y: popup.heroHeight
                width: parent.width - 16
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Core.Colors.glassBorder
            }
        }

        // Apply rounded mask
        OpacityMask {
            anchors.fill: visualContent
            source: visualContent
            maskSource: mask
        }

        // Close button (interactive, over hero)
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 16
            text: Core.Icons.close
            color: closeArea.containsMouse ? Core.Colors.text : Core.Colors.overlay1
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13

            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: popup.close()
            }
        }

        // Scrollable content (interactive, on top of masked visuals)
        Flickable {
            id: contentFlickable
            y: popup.heroHeight + 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            height: parent.height - popup.heroHeight - 16
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
