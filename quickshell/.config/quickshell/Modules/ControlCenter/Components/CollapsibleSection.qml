import QtQuick
import QtQuick.Layouts
import "../../../Core" as Core

Item {
    id: root

    property string title: ""
    property string icon: ""
    property bool expanded: false
    property string rightText: ""
    property string actionIcon: ""
    signal actionClicked()
    default property alias content: contentContainer.data

    implicitWidth: parent?.width ?? 300
    implicitHeight: header.height + contentWrapper.height

    // Header
    Rectangle {
        id: header
        width: parent.width
        height: 36
        radius: expanded ? 0 : 10
        color: headerArea.containsMouse ? Core.Colors.surface1 : Core.Colors.surface0

        Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Text {
                text: root.icon
                color: Core.Colors.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                visible: text !== ""
            }

            Text {
                text: root.title
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            Text {
                text: root.rightText
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                visible: text !== ""
            }

            Text {
                text: root.actionIcon
                color: actionArea.containsMouse ? Core.Colors.accent : Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                visible: root.actionIcon !== ""

                Behavior on color { ColorAnimation { duration: Core.Animations.durationFast } }

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function(event) {
                        event.accepted = true
                        root.actionClicked()
                    }
                }
            }

            Text {
                text: expanded ? Core.Icons.chevron_up : Core.Icons.chevron_down
                color: Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10

                Behavior on text { enabled: false }
                rotation: expanded ? 0 : 0
            }
        }

        MouseArea {
            id: headerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // Content wrapper with animated height
    Item {
        id: contentWrapper
        anchors.top: header.bottom
        width: parent.width
        height: expanded ? contentContainer.implicitHeight : 0
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Core.Animations.durationNormal
                easing.type: Core.Animations.easingType
            }
        }

        ColumnLayout {
            id: contentContainer
            width: parent.width
            spacing: 6
        }
    }
}
