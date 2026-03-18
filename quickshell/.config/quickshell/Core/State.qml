pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property bool launcherOpen: false
    property bool powerMenuOpen: false

    function toggleLauncher() { launcherOpen = !launcherOpen }
    function togglePowerMenu() { powerMenuOpen = !powerMenuOpen }

    IpcHandler {
        target: "launcher"
        function handleCall(action: string) {
            if (action === "toggle") toggleLauncher()
        }
    }

    IpcHandler {
        target: "powermenu"
        function handleCall(action: string) {
            if (action === "toggle") togglePowerMenu()
        }
    }
}
