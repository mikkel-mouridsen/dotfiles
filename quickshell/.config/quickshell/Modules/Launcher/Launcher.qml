import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../Core" as Core

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

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            searchField.forceActiveFocus()
        }
    }

    // Click backdrop to close
    MouseArea {
        anchors.fill: parent
        onClicked: Core.State.launcherOpen = false
    }

    // Centered search + results panel
    Rectangle {
        anchors.centerIn: parent
        width: 500
        height: Math.min(appList.implicitHeight + 80, parent.height * 0.6)
        color: Core.Colors.glass
        radius: 20
        border.width: 1
        border.color: Core.Colors.glassBorder

        // Prevent backdrop click from closing when clicking panel
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: appList
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Search box
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: Core.Colors.surface0
                radius: 12

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: Core.Icons.search
                        color: Core.Colors.overlay0
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

                        Keys.onEscapePressed: Core.State.launcherOpen = false
                        Keys.onReturnPressed: {
                            if (filteredModel.count > 0) {
                                filteredModel.get(listView.currentIndex ?? 0).entry.launch()
                                Core.State.launcherOpen = false
                            }
                        }
                        Keys.onDownPressed: {
                            if (listView.currentIndex < filteredModel.count - 1)
                                listView.currentIndex++
                        }
                        Keys.onUpPressed: {
                            if (listView.currentIndex > 0)
                                listView.currentIndex--
                        }
                    }
                }
            }

            // Results list
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                currentIndex: 0

                model: ListModel {
                    id: filteredModel
                }

                delegate: Rectangle {
                    required property int index
                    required property var entry
                    width: listView.width
                    height: 44
                    radius: 10
                    color: listView.currentIndex === index
                        ? Core.Colors.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Image {
                            source: entry.icon ?? ""
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: entry.name ?? ""
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
                            entry.launch()
                            Core.State.launcherOpen = false
                        }
                    }
                }
            }
        }

        // Filter apps on search text change
        Connections {
            target: searchField
            function onTextChanged() {
                filteredModel.clear()
                let query = searchField.text.toLowerCase()
                let entries = DesktopEntries.applications.values
                for (let i = 0; i < entries.length; i++) {
                    let app = entries[i]
                    if (!app.noDisplay && app.name.toLowerCase().includes(query)) {
                        filteredModel.append({ entry: app })
                    }
                }
                listView.currentIndex = 0
            }
        }
    }

    // Keyboard shortcut to close
    Shortcut {
        sequence: "Escape"
        onActivated: Core.State.launcherOpen = false
    }
}
