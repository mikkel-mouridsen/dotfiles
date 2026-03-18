import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    Component.onCompleted: console.log("Quickshell loaded")

    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData
            property var screen: modelData

            Loader {
                source: "Modules/Bar/BarWindow.qml"
                property var targetScreen: screen
            }
        }
    }

    Loader { source: "Modules/Launcher/Launcher.qml" }
    Loader { source: "Modules/PowerMenu/PowerMenu.qml" }
    Loader { source: "Modules/Notifications/NotificationPopup.qml" }
}
