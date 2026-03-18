import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../Core" as Core
import "../../Services" as Services

PanelWindow {
    id: notifWindow

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 50
        right: 12
    }

    implicitWidth: 380
    implicitHeight: notifColumn.implicitHeight + 16
    color: "transparent"
    visible: notifModel.count > 0
    exclusionMode: ExclusionMode.Ignore

    ListModel {
        id: notifModel
    }

    Connections {
        target: Services.NotificationService
        function onNewNotification(notification) {
            // Keep at most 3 visible
            while (notifModel.count >= 3) {
                notifModel.remove(0)
            }
            notifModel.append({ notif: notification })

            // Auto-dismiss after 5 seconds
            let timer = Qt.createQmlObject(
                'import QtQuick; Timer { interval: 5000; running: true; repeat: false }',
                notifWindow
            )
            timer.triggered.connect(() => {
                for (let i = 0; i < notifModel.count; i++) {
                    if (notifModel.get(i).notif === notification) {
                        notifModel.remove(i)
                        break
                    }
                }
                timer.destroy()
            })
        }
    }

    ColumnLayout {
        id: notifColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 8

        Repeater {
            model: notifModel

            Rectangle {
                required property var notif
                Layout.fillWidth: true
                height: notifContent.implicitHeight + 24
                radius: 14
                color: Core.Colors.glass
                border.width: 1
                border.color: notif.urgency === NotificationUrgency.Critical
                    ? Core.Colors.red : Core.Colors.glassBorder

                RowLayout {
                    id: notifContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Image {
                        source: notif.appIcon ?? ""
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        fillMode: Image.PreserveAspectFit
                        visible: source != ""
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: notif.summary ?? ""
                            color: Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: notif.body ?? ""
                            color: Core.Colors.subtext0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: Core.Icons.close
                        color: Core.Colors.overlay0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignTop

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                for (let i = 0; i < notifModel.count; i++) {
                                    if (notifModel.get(i).notif === notif) {
                                        notifModel.remove(i)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }

                // Fade in
                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity {
                    NumberAnimation { duration: Core.Animations.durationNormal }
                }
            }
        }
    }
}
