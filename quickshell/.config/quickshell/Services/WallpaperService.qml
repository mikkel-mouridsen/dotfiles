pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property string currentWallpaper: ""
    property ListModel wallpapers: ListModel {}

    function refresh() {
        scanProc.running = true
    }

    function setWallpaper(path) {
        currentWallpaper = path
        applyProc.command = ["swww", "img", path,
            "--transition-type", "center",
            "--transition-duration", "1",
            "--transition-fps", "60"]
        applyProc.running = true
    }

    Process {
        id: scanProc
        command: ["sh", "-c", "find ~/.config/wallpapers -maxdepth 1 -type f -iregex '.*\\.\\(jpg\\|jpeg\\|png\\|webp\\)' | sort"]

        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "") {
                    wallpapers.append({ path: data.trim() })
                }
            }
        }

        onRunningChanged: {
            if (running) wallpapers.clear()
        }
    }

    Process {
        id: applyProc
    }

    Process {
        id: queryProc
        command: ["swww", "query"]
        stdout: SplitParser {
            onRead: data => {
                let match = data.match(/image: (.+)/)
                if (match) currentWallpaper = match[1].trim()
            }
        }
    }

    Component.onCompleted: {
        queryProc.running = true
        refresh()
    }
}
