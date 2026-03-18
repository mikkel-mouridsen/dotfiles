import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../../Core" as Core

Item {
    id: musicWidget
    visible: player != null
    implicitWidth: visible ? musicRow.implicitWidth + 20 : 0
    implicitHeight: 32

    property var player: {
        // Prefer YouTube Music, fall back to any active player
        for (let i = 0; i < Mpris.players.values.length; i++) {
            let p = Mpris.players.values[i]
            if (p.identity.toLowerCase().includes("youtube")) return p
        }
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    }

    Rectangle {
        anchors.fill: parent
        color: Core.Colors.surface0
        radius: 10
        border.width: 1
        border.color: player?.playbackStatus === MprisPlaybackStatus.Playing
            ? Core.Colors.green : Core.Colors.glassBorder

        RowLayout {
            id: musicRow
            anchors.centerIn: parent
            spacing: 8

            // Album art
            Image {
                source: player?.trackArtUrl ?? ""
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                fillMode: Image.PreserveAspectCrop
                visible: source != ""

                layer.enabled: true
                layer.effect: Item {
                    // Rounded mask via OpacityMask alternative
                }
            }

            // Track info
            Text {
                text: player?.trackTitle ?? ""
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.maximumWidth: 180
            }

            Text {
                text: player?.trackArtists?.join(", ") ?? ""
                color: Core.Colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.maximumWidth: 120
                visible: text !== ""
            }

            // Controls (visible on hover)
            RowLayout {
                spacing: 4
                visible: musicArea.containsMouse

                Text {
                    text: Core.Icons.music_prev
                    color: Core.Colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        onClicked: player?.previous()
                    }
                }

                Text {
                    text: player?.playbackStatus === MprisPlaybackStatus.Playing
                        ? Core.Icons.music_pause : Core.Icons.music_play
                    color: Core.Colors.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        onClicked: player?.togglePlaying()
                    }
                }

                Text {
                    text: Core.Icons.music_next
                    color: Core.Colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        onClicked: player?.next()
                    }
                }
            }
        }
    }

    MouseArea {
        id: musicArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
