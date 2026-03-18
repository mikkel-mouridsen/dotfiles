import QtQuick
import QtQuick.Layouts
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

    implicitHeight: 420

    margins.top: 56

    visible: Core.State.musicPlayerOpen
    color: "transparent"

    // Input mask: only the panel rectangle receives clicks
    mask: Region { item: panel }


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

    // Panel — centered, solid
    Rectangle {
        id: panel
        width: 340
        height: 420
        anchors.horizontalCenter: parent.horizontalCenter
        color: Core.Colors.mantle
        radius: 16
        border.width: 1
        border.color: Core.Colors.glassBorder

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 0

            // Header: identity + close button
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: Services.MprisService.identity
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
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
                        onClicked: popup.close()
                    }
                }
            }

            Item { Layout.preferredHeight: 14 }

            // Album art
            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                radius: 14
                color: Core.Colors.surface0
                clip: true

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: Services.MprisService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: Core.Icons.music_note
                    color: Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 44
                    visible: albumArt.status !== Image.Ready
                }
            }

            Item { Layout.preferredHeight: 14 }

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

            Item { Layout.preferredHeight: 10 }

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

            Item { Layout.fillHeight: true }

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
