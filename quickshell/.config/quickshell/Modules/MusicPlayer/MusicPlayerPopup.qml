import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../Core" as Core
import "../../Services" as Services

PanelWindow {
    id: popup

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "musicplayer"

    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 370

    margins.top: 56

    visible: Core.State.musicPlayerOpen
    color: "transparent"

    mask: Region { item: borderGlow }

    property int heroHeight: 160

    function close() { Core.State.musicPlayerOpen = false }

    function formatTime(microseconds) {
        let totalSeconds = Math.floor(microseconds / 1000000)
        let minutes = Math.floor(totalSeconds / 60)
        let seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    property real displayPosition: Services.MprisService.position

    onVisibleChanged: {
        if (visible) displayPosition = Services.MprisService.position
    }

    Connections {
        target: Services.MprisService
        function onPositionChanged() { displayPosition = Services.MprisService.position }
        function onTitleChanged() { displayPosition = Services.MprisService.position }
    }

    Timer {
        interval: 1000
        repeat: true
        running: popup.visible && Services.MprisService.playing
        onTriggered: displayPosition += 1000000
    }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }

    // Gradient border (mauve → lavender)
    Rectangle {
        id: borderGlow
        anchors.centerIn: panel
        width: panel.width + 4
        height: panel.height + 4
        radius: 18
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0.796, 0.651, 0.969, 0.67) }
            GradientStop { position: 1.0; color: Qt.rgba(0.706, 0.745, 0.996, 0.67) }
        }
    }

    // Single unified card
    Item {
        id: panel
        width: 380
        height: 350
        anchors.horizontalCenter: parent.horizontalCenter

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

            // Cover art hero (top)
            Image {
                width: parent.width
                height: popup.heroHeight
                source: Services.MprisService.artUrl
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignVCenter
                visible: status === Image.Ready
            }

            // Fallback hero background when no art
            Rectangle {
                width: parent.width
                height: popup.heroHeight
                color: Core.Colors.surface0
                visible: Services.MprisService.artUrl === ""
            }

            // Fallback music note icon
            Text {
                width: parent.width
                y: 0
                height: popup.heroHeight
                text: Core.Icons.music_note
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 44
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: Services.MprisService.artUrl === ""
            }

            // Darken cover art + gradient fade
            Rectangle {
                width: parent.width
                height: popup.heroHeight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 0.6; color: Qt.rgba(0.118, 0.118, 0.180, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                }
            }

            // Player identity on hero
            Text {
                x: 16
                y: 16
                text: Services.MprisService.identity
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

        // Block pass-through clicks
        MouseArea { anchors.fill: parent }

        // Close button (interactive, over hero)
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
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
                onClicked: popup.close()
            }
        }

        // Interactive content below hero
        ColumnLayout {
            y: popup.heroHeight + 14
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height - popup.heroHeight - 20
            spacing: 0

            // Song title
            Text {
                text: Services.MprisService.title
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Artist
            Text {
                text: Services.MprisService.artist
                color: Core.Colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
            }

            Item { Layout.preferredHeight: 12 }

            // Progress bar
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16

                property bool hovered: progressArea.containsMouse
                property real progress: Services.MprisService.length > 0
                    ? Math.min(displayPosition / Services.MprisService.length, 1.0) : 0

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Core.Colors.surface1

                    Rectangle {
                        width: parent.width * parent.parent.progress
                        height: parent.height
                        radius: 2
                        color: Core.Colors.accent
                    }
                }

                Rectangle {
                    x: parent.width * parent.progress - 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12
                    height: 12
                    radius: 6
                    color: Core.Colors.accent
                    visible: parent.hovered
                }

                MouseArea {
                    id: progressArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            // Time labels
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: formatTime(displayPosition)
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: formatTime(Services.MprisService.length)
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }
            }

            Item { Layout.preferredHeight: 10 }

            // Transport controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 28

                Text {
                    text: Core.Icons.music_prev
                    color: prevArea.containsMouse ? Core.Colors.text : Core.Colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    opacity: Services.MprisService.canGoPrevious ? 1.0 : 0.3

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: Services.MprisService.canGoPrevious
                        onClicked: Services.MprisService.previous()
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: playArea.containsMouse
                        ? Qt.lighter(Core.Colors.accent, 1.15) : Core.Colors.accent
                    scale: playArea.pressed ? 0.92 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: Services.MprisService.playing
                            ? Core.Icons.music_pause : Core.Icons.music_play
                        color: Core.Colors.crust
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.MprisService.playPause()
                    }
                }

                Text {
                    text: Core.Icons.music_next
                    color: nextArea.containsMouse ? Core.Colors.text : Core.Colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    opacity: Services.MprisService.canGoNext ? 1.0 : 0.3

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: Services.MprisService.canGoNext
                        onClicked: Services.MprisService.next()
                    }
                }
            }

            Item { Layout.preferredHeight: 6 }
        }
    }
}
