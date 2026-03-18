import QtQuick
import QtQuick.Layouts
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    title: "Notifications"
    icon: Core.Icons.notification
    rightText: Services.NotificationService.unreadCount > 0
        ? Services.NotificationService.unreadCount + " new" : ""
    expanded: false

    // Clear all button in header area
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: Math.max(clearRow.height, notifList.implicitHeight + clearRow.height + 4)

        RowLayout {
            id: clearRow
            width: parent.width
            spacing: 8

            Item { Layout.fillWidth: true }

            Text {
                text: Core.Icons.clear_all + "  Clear All"
                color: clearArea.containsMouse ? Core.Colors.text : Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                visible: Services.NotificationService.history.count > 0

                Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.NotificationService.clearAll()
                }
            }
        }

        ColumnLayout {
            id: notifList
            anchors.top: clearRow.bottom
            anchors.topMargin: 4
            width: parent.width
            spacing: 4

            Repeater {
                model: Services.NotificationService.history

                Rectangle {
                    Layout.fillWidth: true
                    height: notifContent.implicitHeight + 16
                    radius: 10
                    color: Core.Colors.surface0

                    ColumnLayout {
                        id: notifContent
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: model.appName
                                color: Core.Colors.overlay0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: model.timestamp
                                color: Core.Colors.overlay0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                            }

                            Text {
                                text: Core.Icons.close
                                color: dismissArea.containsMouse ? Core.Colors.text : Core.Colors.overlay0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10

                                MouseArea {
                                    id: dismissArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Services.NotificationService.dismiss(index)
                                }
                            }
                        }

                        Text {
                            text: model.summary
                            color: Core.Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            visible: text !== ""
                        }

                        Text {
                            text: model.body
                            color: Core.Colors.subtext0
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            visible: text !== ""
                        }
                    }
                }
            }

            // Empty state
            Text {
                visible: Services.NotificationService.history.count === 0
                text: "No notifications"
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }
        }
    }
}
