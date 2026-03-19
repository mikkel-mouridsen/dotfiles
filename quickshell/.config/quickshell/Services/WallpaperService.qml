pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property string currentWallpaper: ""
    property ListModel wallpapers: ListModel {}
    property bool hasMatugen: false

    function refresh() {
        scanProc.running = true
    }

    function setWallpaper(path) {
        currentWallpaper = path
        console.log("[WallpaperService] setWallpaper:", path, "hasMatugen:", hasMatugen)
        // Always set wallpaper via swww first
        swwwProc.command = ["swww", "img", path,
            "--transition-type", "center",
            "--transition-duration", "1",
            "--transition-fps", "60"]
        swwwProc.running = true
        // Then generate theme if matugen is available
        if (hasMatugen) {
            console.log("[WallpaperService] Running matugen...")
            matugenProc.command = ["matugen", "image", "--source-color-index", "0", path]
            matugenProc.running = true
        }
    }

    Process {
        id: matugenCheck
        command: ["which", "matugen"]
        onExited: (exitCode, exitStatus) => {
            hasMatugen = exitCode === 0
            console.log("[WallpaperService] matugen check:", exitCode, "hasMatugen:", hasMatugen)
        }
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
        id: swwwProc
    }

    Process {
        id: matugenProc
        onExited: (exitCode, exitStatus) => {
            console.log("[WallpaperService] matugen exited:", exitCode)
            if (exitCode === 0) {
                restartProc.running = true
            }
        }
    }

    Process {
        id: restartProc
        command: ["sh", "-c", "quickshell -d 2>/dev/null && sleep 0.3 && quickshell kill 2>/dev/null; true"]
        onExited: (exitCode, exitStatus) => {
            console.log("[WallpaperService] restart exited:", exitCode)
        }
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
        matugenCheck.running = true
        queryProc.running = true
        refresh()
    }
}
