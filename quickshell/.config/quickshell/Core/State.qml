pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property bool launcherOpen: false
    property bool powerMenuOpen: false
    property bool musicPlayerOpen: false
    property bool controlCenterOpen: false

    function closeAll() {
        launcherOpen = false
        powerMenuOpen = false
        musicPlayerOpen = false
        controlCenterOpen = false
    }

    function toggleLauncher() {
        let next = !launcherOpen
        closeAll()
        launcherOpen = next
    }

    function togglePowerMenu() {
        let next = !powerMenuOpen
        closeAll()
        powerMenuOpen = next
    }

    function toggleMusicPlayer() {
        let next = !musicPlayerOpen
        closeAll()
        musicPlayerOpen = next
    }

    function toggleControlCenter() {
        let next = !controlCenterOpen
        closeAll()
        controlCenterOpen = next
    }

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

    IpcHandler {
        target: "musicplayer"
        function handleCall(action: string) {
            if (action === "toggle") toggleMusicPlayer()
        }
    }

    IpcHandler {
        target: "controlcenter"
        function handleCall(action: string) {
            if (action === "toggle") toggleControlCenter()
        }
    }
}
