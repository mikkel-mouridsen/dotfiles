import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../../Core" as Core

RowLayout {
    spacing: 4

    Repeater {
        model: SystemTray.items

        Rectangle {
            required property var modelData
            width: 28
            height: 28
            radius: 8
            color: trayArea.containsMouse ? Core.Colors.surface1 : "transparent"

            Image {
                anchors.centerIn: parent
                source: modelData.icon
                width: 18
                height: 18
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: trayArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate()
                    } else {
                        modelData.secondaryActivate()
                    }
                }
            }
        }
    }
}
