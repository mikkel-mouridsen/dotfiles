import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    title: "Audio"
    icon: Core.Icons.volumeIcon(Services.VolumeService.volume, Services.VolumeService.muted)
    rightText: Services.VolumeService.volume + "%"
    expanded: true

    // Volume slider
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 10

        Text {
            text: Core.Icons.volumeIcon(Services.VolumeService.volume, Services.VolumeService.muted)
            color: Services.VolumeService.muted ? Core.Colors.overlay0 : Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.VolumeService.toggleMute()
            }
        }

        // Custom slider track
        Item {
            Layout.fillWidth: true
            height: 24

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 3
                color: Core.Colors.surface1

                Rectangle {
                    width: parent.width * (Services.VolumeService.volume / 100)
                    height: parent.height
                    radius: 3
                    color: Services.VolumeService.muted ? Core.Colors.overlay0 : Core.Colors.accent

                    Behavior on width {
                        NumberAnimation { duration: Core.Animations.durationFast }
                    }
                }
            }

            // Slider knob
            Rectangle {
                x: parent.width * (Services.VolumeService.volume / 100) - 7
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14
                radius: 7
                color: Core.Colors.text
                visible: sliderArea.containsMouse || sliderArea.pressed
            }

            MouseArea {
                id: sliderArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateVolume(mouse) {
                    let pct = Math.round(Math.max(0, Math.min(150, (mouse.x / width) * 150)))
                    Services.VolumeService.setVolume(pct)
                }

                onClicked: function(mouse) { updateVolume(mouse) }
                onPositionChanged: function(mouse) {
                    if (pressed) updateVolume(mouse)
                }
            }
        }

        Text {
            text: Services.VolumeService.volume + "%"
            color: Core.Colors.subtext0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            Layout.preferredWidth: 32
            horizontalAlignment: Text.AlignRight
        }
    }

    // Output device list
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: deviceColumn.implicitHeight

        ColumnLayout {
            id: deviceColumn
            width: parent.width
            spacing: 2

            Text {
                text: "Output Device"
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                Layout.bottomMargin: 2
            }

            Repeater {
                model: {
                    let sinks = []
                    if (!Pipewire.nodes) return sinks
                    for (let i = 0; i < Pipewire.nodes.values.length; i++) {
                        let node = Pipewire.nodes.values[i]
                        if (node.isSink && !node.isStream) sinks.push(node)
                    }
                    return sinks
                }

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 30
                    radius: 8
                    color: deviceArea.containsMouse ? Core.Colors.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        // Radio indicator
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: "transparent"
                            border.width: 2
                            border.color: modelData === Pipewire.defaultAudioSink
                                ? Core.Colors.accent : Core.Colors.overlay0

                            Rectangle {
                                anchors.centerIn: parent
                                width: 6
                                height: 6
                                radius: 3
                                color: Core.Colors.accent
                                visible: modelData === Pipewire.defaultAudioSink
                            }
                        }

                        Text {
                            text: modelData.description || modelData.nickname || modelData.name
                            color: Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: deviceArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                    }
                }
            }
        }
    }
}
