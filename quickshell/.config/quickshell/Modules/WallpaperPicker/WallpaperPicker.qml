import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../Core" as Core
import "../../Services" as Services

PanelWindow {
    id: picker

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper-picker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: Core.State.wallpaperPickerOpen
    color: "transparent"

    property int selectedIndex: 0
    property int columns: 3

    onVisibleChanged: {
        if (visible) {
            Services.WallpaperService.refresh()
            selectedIndex = 0
        }
    }

    function moveSelection(dh, dv) {
        let count = Services.WallpaperService.wallpapers.count
        if (count === 0) return
        let next = selectedIndex + dh + dv * columns
        if (next >= 0 && next < count) selectedIndex = next
    }

    function applySelection() {
        let count = Services.WallpaperService.wallpapers.count
        if (count === 0) return
        let item = Services.WallpaperService.wallpapers.get(selectedIndex)
        if (item) Services.WallpaperService.setWallpaper(item.path)
    }

    // Click backdrop to close
    MouseArea {
        anchors.fill: parent
        onClicked: Core.State.wallpaperPickerOpen = false
    }

    // Gradient border (mauve → lavender like Hyprland active border)
    Rectangle {
        anchors.centerIn: panel
        width: panel.width + 4
        height: panel.height + 4
        radius: 22
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0.796, 0.651, 0.969, 0.67) }
            GradientStop { position: 1.0; color: Qt.rgba(0.706, 0.745, 0.996, 0.67) }
        }
    }

    // Single unified card
    Item {
        id: panel
        anchors.centerIn: parent
        width: 640
        height: 560

        // Rounded mask
        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 20
            visible: false
        }

        // Visual content (rendered offscreen, then masked)
        Item {
            id: content
            anchors.fill: parent
            visible: false

            // Wallpaper hero (top)
            Image {
                width: parent.width
                height: 140
                source: Services.WallpaperService.currentWallpaper
                    ? "file://" + Services.WallpaperService.currentWallpaper : ""
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignVCenter
            }

            // Darken wallpaper + gradient fade into grid
            Rectangle {
                width: parent.width
                height: 140
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 0.6; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                }
            }

            // Title on hero
            Text {
                x: 20
                y: 16
                text: Core.Icons.wallpaper + "  Wallpapers"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            // Grid background
            Rectangle {
                y: 140
                width: parent.width
                height: parent.height - 140
                color: Core.Colors.mantle
            }

            // Separator
            Rectangle {
                y: 140
                width: parent.width - 16
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Core.Colors.glassBorder
            }
        }

        // Apply rounded mask to all visual content
        OpacityMask {
            anchors.fill: content
            source: content
            maskSource: mask
        }

        // Block backdrop clicks on the card area
        MouseArea { anchors.fill: parent }

        // Close button (interactive, over hero)
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 20
            y: 16
            text: Core.Icons.close
            color: closeArea.containsMouse ? Core.Colors.text : Core.Colors.overlay1
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Core.State.wallpaperPickerOpen = false
            }
        }

        // Empty state
        Text {
            visible: Services.WallpaperService.wallpapers.count === 0
            y: 140
            width: parent.width
            height: parent.height - 140
            text: "No wallpapers found in\n~/.config/wallpapers/"
            color: Core.Colors.overlay0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Wallpaper grid (interactive, on top of masked visuals)
        GridView {
            id: grid
            y: 152
            width: parent.width - 24
            height: parent.height - 164
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Services.WallpaperService.wallpapers.count > 0
            clip: true
            cellWidth: Math.floor(width / 3)
            cellHeight: cellWidth * 0.65
            currentIndex: picker.selectedIndex

            model: Services.WallpaperService.wallpapers

            delegate: Item {
                required property string path
                required property int index
                width: grid.cellWidth
                height: grid.cellHeight

                property bool isSelected: index === picker.selectedIndex
                property bool isActive: Services.WallpaperService.currentWallpaper === path

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 10
                    color: Core.Colors.surface0
                    clip: true
                    border.width: isActive || isSelected ? 2 : 0
                    border.color: isActive ? Core.Colors.accent : Core.Colors.subtext0

                    Image {
                        anchors.fill: parent
                        anchors.margins: parent.border.width
                        source: "file://" + path
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 300
                        sourceSize.height: 200
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.width: thumbArea.containsMouse && !isActive && !isSelected ? 2 : 0
                        border.color: Core.Colors.overlay0

                        Behavior on border.width {
                            NumberAnimation { duration: Core.Animations.durationFast }
                        }
                    }

                    MouseArea {
                        id: thumbArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            picker.selectedIndex = index
                            Services.WallpaperService.setWallpaper(path)
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: Core.State.wallpaperPickerOpen = false
    }

    Shortcut {
        sequence: "h"
        onActivated: picker.moveSelection(-1, 0)
    }
    Shortcut {
        sequence: "l"
        onActivated: picker.moveSelection(1, 0)
    }
    Shortcut {
        sequence: "j"
        onActivated: picker.moveSelection(0, 1)
    }
    Shortcut {
        sequence: "k"
        onActivated: picker.moveSelection(0, -1)
    }
    Shortcut {
        sequence: "Return"
        onActivated: picker.applySelection()
    }
}
