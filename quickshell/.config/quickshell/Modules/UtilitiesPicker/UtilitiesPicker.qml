import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../Core" as Core
import "../../Services" as Services

PanelWindow {
    id: picker

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "utilitiespicker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: Core.State.utilitiesPickerOpen
    color: "transparent"

    property int columns: 3
    property int selectedIndex: 0

    property var utilities: [
        { icon: Core.Icons.bluetooth, label: "Bluetui", cmd: "ghostty -e bluetui" },
        { icon: Core.Icons.vpn, label: "Tailscale", cmd: "ghostty -e tsui" },
        { icon: Core.Icons.volume_high, label: "Audio Mixer", cmd: "ghostty -e wiremix" },
        { icon: Core.Icons.nas, label: "NAS Storage", cmd: "__controlcenter_nas__" },
        { icon: Core.Icons.wifi, label: "Network", cmd: "ghostty -e nmtui" },
        { icon: Core.Icons.wallpaper, label: "Wallpaper", cmd: "__wallpaper__" },
    ]

    function launch(index) {
        let util = utilities[index]
        if (util.cmd === "__wallpaper__") {
            Core.State.utilitiesPickerOpen = false
            Core.State.toggleWallpaperPicker()
        } else if (util.cmd === "__controlcenter_nas__") {
            Core.State.utilitiesPickerOpen = false
            Core.State.toggleControlCenter()
        } else {
            Hyprland.dispatch("exec [float;size 900 600;center] " + util.cmd)
            Core.State.utilitiesPickerOpen = false
        }
    }

    onVisibleChanged: {
        if (visible) selectedIndex = 0
    }

    // Click backdrop to close
    MouseArea {
        anchors.fill: parent
        onClicked: Core.State.utilitiesPickerOpen = false
    }

    Item {
        id: panel
        anchors.centerIn: parent
        width: 420
        height: heroHeight + gridContainer.implicitHeight + 32

        property int heroHeight: 120

        // Rounded mask
        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 20
            visible: false
        }

        // Visual content
        Item {
            id: content
            anchors.fill: parent
            visible: false

            // Wallpaper hero
            Image {
                width: parent.width
                height: panel.heroHeight
                source: Services.WallpaperService.currentWallpaper
                    ? "file://" + Services.WallpaperService.currentWallpaper : ""
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignVCenter
            }

            // Darken wallpaper
            Rectangle {
                width: parent.width
                height: panel.heroHeight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 0.6; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                }
            }

            // Title
            Text {
                x: 16
                y: 16
                text: "System Utilities"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            // Subtitle
            Text {
                x: 16
                y: 38
                text: "Quick access to system tools"
                color: Core.Colors.overlay1
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }

            // Content background
            Rectangle {
                y: panel.heroHeight
                width: parent.width
                height: parent.height - panel.heroHeight
                color: Core.Colors.mantle
            }

            // Separator
            Rectangle {
                y: panel.heroHeight
                width: parent.width - 16
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Core.Colors.glassBorder
            }
        }

        OpacityMask {
            anchors.fill: content
            source: content
            maskSource: mask
        }

        // Border overlay
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: "transparent"
            border.width: 1
            border.color: Core.Colors.glassBorder
        }

        // Grid content (interactive, on top)
        Item {
            id: gridContainer
            y: panel.heroHeight + 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            implicitHeight: grid.implicitHeight

            GridLayout {
                id: grid
                width: parent.width
                columns: picker.columns
                rowSpacing: 12
                columnSpacing: 12

                Repeater {
                    model: picker.utilities.length

                    Rectangle {
                        required property int index
                        readonly property var util: picker.utilities[index]
                        readonly property bool selected: picker.selectedIndex === index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        radius: 12
                        color: selected
                            ? Core.Colors.surface1
                            : tileArea.containsMouse ? Core.Colors.surface0 : Qt.rgba(0, 0, 0, 0)

                        Behavior on color { ColorAnimation { duration: 100 } }

                        border.width: selected ? 1 : 0
                        border.color: Core.Colors.accent

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: util.icon
                                color: selected ? Core.Colors.accent : Core.Colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 24
                                Layout.alignment: Qt.AlignHCenter

                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            Text {
                                text: util.label
                                color: Core.Colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: tileArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: picker.selectedIndex = index
                            onClicked: picker.launch(index)
                        }
                    }
                }
            }
        }

        // Keyboard navigation (on top of everything)
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            focus: picker.visible

            Keys.onEscapePressed: Core.State.utilitiesPickerOpen = false
            Keys.onReturnPressed: picker.launch(picker.selectedIndex)
            Keys.onRightPressed: {
                if (picker.selectedIndex < picker.utilities.length - 1)
                    picker.selectedIndex++
            }
            Keys.onLeftPressed: {
                if (picker.selectedIndex > 0)
                    picker.selectedIndex--
            }
            Keys.onDownPressed: {
                let next = picker.selectedIndex + picker.columns
                if (next < picker.utilities.length)
                    picker.selectedIndex = next
            }
            Keys.onUpPressed: {
                let prev = picker.selectedIndex - picker.columns
                if (prev >= 0)
                    picker.selectedIndex = prev
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: Core.State.utilitiesPickerOpen = false
    }
}
