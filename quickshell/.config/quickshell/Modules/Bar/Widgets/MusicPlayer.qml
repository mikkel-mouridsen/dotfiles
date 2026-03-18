import QtQuick
import QtQuick.Layouts
import "../../../Core" as Core
import "../../../Services" as Services

Item {
    id: musicWidget
    visible: Services.MprisService.title !== ""
    implicitWidth: visible ? musicRow.implicitWidth + 20 : 0
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        color: Core.Colors.surface0
        radius: 10
        border.width: 1
        border.color: Services.MprisService.playing
            ? Core.Colors.green : Core.Colors.glassBorder

        RowLayout {
            id: musicRow
            anchors.centerIn: parent
            spacing: 8

            // Equalizer bars animation
            Row {
                spacing: 2
                visible: Services.MprisService.playing
                Layout.preferredWidth: 14
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: 3
                    Rectangle {
                        required property int index
                        width: 3
                        height: 4
                        radius: 1
                        color: Core.Colors.green
                        anchors.bottom: parent.bottom

                        SequentialAnimation on height {
                            loops: Animation.Infinite
                            running: Services.MprisService.playing
                            NumberAnimation {
                                from: 4; to: 14
                                duration: index === 0 ? 300 : index === 1 ? 400 : 500
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                from: 14; to: 4
                                duration: index === 0 ? 300 : index === 1 ? 400 : 500
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }

            // Album art
            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 4
                color: Core.Colors.surface1
                clip: true

                Image {
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
                    font.pixelSize: 12
                    visible: albumArt.status !== Image.Ready

                    property Item albumArt: parent.children[0]
                }
            }

            // Track title
            Text {
                text: Services.MprisService.title
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.maximumWidth: 180
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Core.State.toggleMusicPlayer()
    }
}
