import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../Core" as Core
import "../../../Services" as Services
import "../Components" as Components

Components.CollapsibleSection {
    id: root
    title: "Network Storage"
    icon: Core.Icons.nas
    rightText: {
        let count = (Services.NetworkStorageService.docsActive ? 1 : 0)
            + (Services.NetworkStorageService.mediaActive ? 1 : 0)
        if (!Services.NetworkStorageService.serverReachable) return "offline"
        return count + "/2 mounted"
    }
    expanded: false

    onExpandedChanged: {
        Services.NetworkStorageService.pollingEnabled = expanded && Core.State.controlCenterOpen
    }

    Connections {
        target: Core.State
        function onControlCenterOpenChanged() {
            Services.NetworkStorageService.pollingEnabled = root.expanded && Core.State.controlCenterOpen
        }
    }

    // Server status
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 8

        Text {
            text: "Server"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Text {
            text: Services.NetworkStorageService.serverName
            color: Core.Colors.overlay0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
        }

        Rectangle {
            width: reachLabel.implicitWidth + 10
            height: 18
            radius: 9
            color: Services.NetworkStorageService.serverReachable ? Core.Colors.green : Core.Colors.red
            opacity: 0.2

            Text {
                id: reachLabel
                anchors.centerIn: parent
                text: Services.NetworkStorageService.serverReachable ? "Reachable" : "Offline"
                color: Services.NetworkStorageService.serverReachable ? Core.Colors.green : Core.Colors.red
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
            }
        }
    }

    // Documents mount
    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        height: 32
        radius: 8
        color: docsArea.containsMouse ? Core.Colors.surface1 : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: Core.Icons.nas
                color: Services.NetworkStorageService.docsActive ? Core.Colors.accent : Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }

            Text {
                text: "Documents"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            Rectangle {
                width: docsStatusLabel.implicitWidth + 10
                height: 18
                radius: 9
                color: Services.NetworkStorageService.docsActive ? Core.Colors.accent : Core.Colors.surface1
                opacity: Services.NetworkStorageService.docsActive ? 0.2 : 1.0

                Text {
                    id: docsStatusLabel
                    anchors.centerIn: parent
                    text: Services.NetworkStorageService.docsActive ? "Mounted" : "Unmounted"
                    color: Services.NetworkStorageService.docsActive ? Core.Colors.accent : Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                }
            }
        }

        MouseArea {
            id: docsArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.NetworkStorageService.remountDocs()
        }
    }

    // Media mount
    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        height: 32
        radius: 8
        color: mediaArea.containsMouse ? Core.Colors.surface1 : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: Core.Icons.nas
                color: Services.NetworkStorageService.mediaActive ? Core.Colors.accent : Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }

            Text {
                text: "Media"
                color: Core.Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            Rectangle {
                width: mediaStatusLabel.implicitWidth + 10
                height: 18
                radius: 9
                color: Services.NetworkStorageService.mediaActive ? Core.Colors.accent : Core.Colors.surface1
                opacity: Services.NetworkStorageService.mediaActive ? 0.2 : 1.0

                Text {
                    id: mediaStatusLabel
                    anchors.centerIn: parent
                    text: Services.NetworkStorageService.mediaActive ? "Mounted" : "Unmounted"
                    color: Services.NetworkStorageService.mediaActive ? Core.Colors.accent : Core.Colors.overlay0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                }
            }
        }

        MouseArea {
            id: mediaArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.NetworkStorageService.remountMedia()
        }
    }

    // Reconnect All button (visible when something is unmounted)
    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        Layout.topMargin: 4
        height: 30
        radius: 8
        color: reconnectArea.containsMouse ? Core.Colors.surface1 : Core.Colors.surface0
        visible: !Services.NetworkStorageService.docsActive || !Services.NetworkStorageService.mediaActive

        Text {
            anchors.centerIn: parent
            text: Core.Icons.sync_icon + "  Reconnect All"
            color: Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }

        MouseArea {
            id: reconnectArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.NetworkStorageService.remountAll()
        }
    }

    // Separator
    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Layout.rightMargin: 20
        Layout.topMargin: 4
        height: 1
        color: Core.Colors.glassBorder
    }

    // Sync timer status
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 8

        Text {
            text: Core.Icons.sync_icon
            color: Services.NetworkStorageService.syncTimerActive ? Core.Colors.accent : Core.Colors.overlay0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }

        Text {
            text: "Sync Timer"
            color: Core.Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Rectangle {
            width: syncStatusLabel.implicitWidth + 10
            height: 18
            radius: 9
            color: Services.NetworkStorageService.syncTimerActive ? Core.Colors.accent : Core.Colors.surface1
            opacity: Services.NetworkStorageService.syncTimerActive ? 0.2 : 1.0

            Text {
                id: syncStatusLabel
                anchors.centerIn: parent
                text: Services.NetworkStorageService.syncTimerActive ? "Active" : "Inactive"
                color: Services.NetworkStorageService.syncTimerActive ? Core.Colors.accent : Core.Colors.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
            }
        }
    }

    // Last sync time
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 8

        Text {
            text: "Last sync"
            color: Core.Colors.overlay0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            Layout.fillWidth: true
        }

        Text {
            text: Services.NetworkStorageService.lastSync || "never"
            color: Core.Colors.overlay0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
        }
    }

    // Sync Now button
    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        Layout.topMargin: 4
        Layout.bottomMargin: 8
        height: 30
        radius: 8
        color: syncArea.containsMouse ? Core.Colors.surface1 : Core.Colors.surface0
        opacity: Services.NetworkStorageService.syncing ? 0.6 : 1.0

        Text {
            anchors.centerIn: parent
            text: Services.NetworkStorageService.syncing
                ? Core.Icons.sync_icon + "  Syncing..."
                : Core.Icons.sync_icon + "  Sync Now"
            color: Core.Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }

        MouseArea {
            id: syncArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Services.NetworkStorageService.syncing ? Qt.BusyCursor : Qt.PointingHandCursor
            onClicked: {
                if (!Services.NetworkStorageService.syncing)
                    Services.NetworkStorageService.triggerSync()
            }
        }
    }
}
