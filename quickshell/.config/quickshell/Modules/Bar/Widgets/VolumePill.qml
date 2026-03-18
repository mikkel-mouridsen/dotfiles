import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../Core" as Core

Rectangle {
    id: volumePill
    color: Core.Colors.surface0
    radius: 10
    width: volumeRow.implicitWidth + 16
    height: 28

    property int volume: 0
    property bool muted: false

    function parseVolume() {
        volumeProc.running = true
    }

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                // Output: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
                volumePill.muted = data.includes("[MUTED]")
                let match = data.match(/Volume:\s+([\d.]+)/)
                if (match) volumePill.volume = Math.round(parseFloat(match[1]) * 100)
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: parseVolume()
    }

    RowLayout {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: Core.Icons.volumeIcon(volume, muted)
            color: muted ? Core.Colors.overlay0 : Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }

        Text {
            text: volume + "%"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            let proc = Qt.createQmlObject(
                'import Quickshell.Io; Process { command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"] }',
                volumePill
            )
            proc.running = true
            parseVolume()
        }
        onWheel: function(event) {
            let dir = event.angleDelta.y > 0 ? "5%+" : "5%-"
            let proc = Qt.createQmlObject(
                'import Quickshell.Io; Process { command: ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "' + dir + '"] }',
                volumePill
            )
            proc.running = true
            parseVolume()
        }
    }
}
