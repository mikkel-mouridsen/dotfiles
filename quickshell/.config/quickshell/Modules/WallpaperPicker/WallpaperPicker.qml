import QtQuick
import QtQuick.Layouts
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

    MouseArea {
        anchors.fill: parent
        onClicked: Core.State.wallpaperPickerOpen = false
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 620
        height: 520
        color: Core.Colors.mantle
        radius: 20
        border.width: 1
        border.color: Core.Colors.glassBorder

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 0

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: Core.Icons.wallpaper + "  Wallpapers"
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                }

                Text {
                    text: Core.Icons.close
                    color: closeArea.containsMouse ? Core.Colors.text : Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Core.State.wallpaperPickerOpen = false
                    }
                }
            }

            Item { Layout.preferredHeight: 14 }

            // Empty state
            Text {
                visible: Services.WallpaperService.wallpapers.count === 0
                text: "No wallpapers found in\n~/.config/wallpapers/"
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
            }

            // Wallpaper grid
            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                            id: thumb
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
