import QtQuick
import "../../../Core" as Core

Rectangle {
    id: clockPill
    color: Core.Colors.surface0
    radius: 10
    width: clockText.implicitWidth + 20
    height: 28

    Text {
        id: clockText
        anchors.centerIn: parent
        color: Core.Colors.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13

        text: Qt.formatTime(new Date(), "hh:mm")

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }
}
