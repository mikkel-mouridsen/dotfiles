import QtQuick
import QtQuick.Layouts
import "../../../Core" as Core

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false

    signal toggled()

    width: 100
    height: 70
    radius: 12
    color: active
        ? (tileArea.containsMouse ? Qt.lighter(Core.Colors.accent, 1.1) : Core.Colors.accent)
        : (tileArea.containsMouse ? Core.Colors.surface1 : Core.Colors.surface0)

    Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: active ? Core.Colors.crust : Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter

            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }
        }

        Text {
            text: root.label
            color: active ? Core.Colors.crust : Core.Colors.subtext0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            Layout.alignment: Qt.AlignHCenter

            Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }
        }
    }

    MouseArea {
        id: tileArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
