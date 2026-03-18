import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../Core" as Core
import "../../Services" as Services

PanelWindow {
    id: launcher

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: Core.State.launcherOpen
    color: "transparent"

    property var filteredEntries: []
    property real resultsHeight: Math.min(Math.max(filteredEntries.length, 1) * 44 + 24, 440)

    function filterApps() {
        let query = searchField.text.toLowerCase()
        let entries = DesktopEntries.applications.values
        let results = []
        for (let i = 0; i < entries.length; i++) {
            let app = entries[i]
            if (app.noDisplay) continue

            let name = (app.name ?? "").toLowerCase()
            let genericName = (app.genericName ?? "").toLowerCase()
            let id = (app.id ?? "").toLowerCase()
            let comment = (app.comment ?? "").toLowerCase()
            let keywords = (app.keywords ?? []).map(k => k.toLowerCase())

            if (name.includes(query)
                || genericName.includes(query)
                || id.includes(query)
                || comment.includes(query)
                || keywords.some(k => k.includes(query))) {
                results.push(app)
            }
        }
        results.sort((a, b) => {
            let aStarts = a.name.toLowerCase().startsWith(query)
            let bStarts = b.name.toLowerCase().startsWith(query)
            if (aStarts !== bStarts) return aStarts ? -1 : 1
            return a.name.localeCompare(b.name)
        })
        filteredEntries = results
        listView.currentIndex = 0
    }

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            searchField.forceActiveFocus()
            filterApps()
        }
    }

    // Click backdrop to close
    MouseArea {
        anchors.fill: parent
        onClicked: Core.State.launcherOpen = false
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
        height: 180 + launcher.resultsHeight

        // Rounded mask
        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 20
            visible: false
        }

        // All content (rendered offscreen, then masked)
        Item {
            id: content
            anchors.fill: parent
            visible: false

            // Wallpaper hero (top)
            Image {
                id: wallpaper
                width: parent.width
                height: 180
                source: Services.WallpaperService.currentWallpaper
                    ? "file://" + Services.WallpaperService.currentWallpaper : ""
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignVCenter
            }

            // Darken wallpaper + gradient fade into results
            Rectangle {
                width: parent.width
                height: 180
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 0.6; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                }
            }

            // Search bar
            Rectangle {
                id: searchBar
                y: 180 - 16 - 44
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 32
                height: 44
                radius: 12
                color: Qt.rgba(0.067, 0.067, 0.106, 0.85)
                border.width: 1
                border.color: Core.Colors.glassBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: Core.Icons.search
                        color: Core.Colors.overlay1
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        color: Core.Colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        clip: true

                        Text {
                            visible: !searchField.text
                            text: "Search applications..."
                            color: Core.Colors.overlay0
                            font: searchField.font
                        }

                        onTextChanged: launcher.filterApps()

                        Keys.onEscapePressed: Core.State.launcherOpen = false
                        Keys.onReturnPressed: {
                            if (launcher.filteredEntries.length > 0) {
                                let idx = listView.currentIndex ?? 0
                                launcher.filteredEntries[idx].execute()
                                Core.State.launcherOpen = false
                            }
                        }
                        Keys.onDownPressed: {
                            if (listView.currentIndex < launcher.filteredEntries.length - 1)
                                listView.currentIndex++
                        }
                        Keys.onUpPressed: {
                            if (listView.currentIndex > 0)
                                listView.currentIndex--
                        }
                    }
                }
            }

            // Results background (matching control center)
            Rectangle {
                y: 180
                width: parent.width
                height: launcher.resultsHeight
                color: Core.Colors.mantle
            }

            // Separator
            Rectangle {
                y: 180
                width: parent.width - 16
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Core.Colors.glassBorder
            }

            // Results list
            ListView {
                id: listView
                y: 180 + 12
                width: parent.width - 16
                height: launcher.resultsHeight - 24
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                currentIndex: 0

                model: launcher.filteredEntries.length

                delegate: Rectangle {
                    required property int index
                    readonly property var entry: launcher.filteredEntries[index]
                    width: listView.width
                    height: 44
                    radius: 10
                    color: listView.currentIndex === index
                        ? Core.Colors.surface1 : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Image {
                            source: {
                                if (!entry || !entry.icon) return ""
                                let path = Quickshell.iconPath(entry.icon)
                                if (!path) return ""
                                if (path.startsWith("/")) return "file://" + path
                                return path
                            }
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: entry ? entry.name ?? "" : ""
                            color: Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: listView.currentIndex = index
                        onClicked: {
                            if (entry) {
                                entry.execute()
                                Core.State.launcherOpen = false
                            }
                        }
                    }
                }
            }
        }

        // Apply rounded mask to all content
        OpacityMask {
            anchors.fill: content
            source: content
            maskSource: mask
        }

        // Click handler on top of the masked output
        MouseArea { anchors.fill: parent }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: Core.State.launcherOpen = false
    }
}
