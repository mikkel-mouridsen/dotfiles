pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property bool docsActive: false
    property bool mediaActive: false
    property bool syncTimerActive: false
    property string lastSync: ""
    property bool serverReachable: false
    property string serverName: "gondor"
    property bool syncing: false
    property bool pollingEnabled: false

    function refresh() {
        if (!statusProc.running) statusProc.running = true
    }

    function remountDocs() {
        remountDocsProc.running = true
    }

    function remountMedia() {
        remountMediaProc.running = true
    }

    function remountAll() {
        remountAllProc.running = true
    }

    function triggerSync() {
        if (!syncing) {
            syncing = true
            syncProc.running = true
        }
    }

    Timer {
        interval: 10000
        running: pollingEnabled
        repeat: true
        onTriggered: refresh()
    }

    // Read server name from config on startup
    Process {
        id: configProc
        command: ["bash", "-c", "source ~/.config/network-storage/config.env 2>/dev/null && echo \"$SMB_SERVER\""]

        stdout: SplitParser {
            onRead: data => {
                if (data.trim()) serverName = data.trim()
            }
        }
    }

    property string _buffer: ""

    Process {
        id: statusProc
        command: ["bash", "-c",
            "docs=$(systemctl is-active mnt-network\\\\x2dstorage-documents.mount 2>/dev/null) || true; " +
            "media=$(systemctl is-active mnt-network\\\\x2dstorage-media.mount 2>/dev/null) || true; " +
            "timer=$(systemctl --user is-active network-storage-sync.timer 2>/dev/null) || true; " +
            "last=$(systemctl --user show network-storage-sync.timer -p LastTriggerUSec --value 2>/dev/null) || true; " +
            "ping -c1 -W2 " + serverName + " &>/dev/null && reach=true || reach=false; " +
            "syncing=$(systemctl --user is-active network-storage-sync.service 2>/dev/null) || true; " +
            "printf '{\"docs\":\"%s\",\"media\":\"%s\",\"timer\":\"%s\",\"lastSync\":\"%s\",\"reachable\":%s,\"syncing\":\"%s\"}\\n' " +
            "\"${docs:-inactive}\" \"${media:-inactive}\" \"${timer:-inactive}\" \"${last:-never}\" \"$reach\" \"${syncing:-inactive}\""
        ]

        stdout: SplitParser {
            onRead: data => {
                _buffer += data + "\n"
            }
        }

        onRunningChanged: {
            if (running) _buffer = ""
        }

        onExited: (exitCode, exitStatus) => {
            try {
                let json = JSON.parse(_buffer)
                docsActive = json.docs === "active"
                mediaActive = json.media === "active"
                syncTimerActive = json.timer === "active"
                serverReachable = json.reachable
                syncing = json.syncing === "active"

                if (json.lastSync && json.lastSync !== "never" && json.lastSync !== "n/a") {
                    let d = new Date(json.lastSync.replace(" UTC", "Z").replace(" ", "T"))
                    if (!isNaN(d.getTime())) {
                        lastSync = d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
                    } else {
                        lastSync = json.lastSync
                    }
                } else {
                    lastSync = "never"
                }
            } catch (e) {
                console.warn("NetworkStorageService: failed to parse JSON:", e)
            }
        }
    }

    Process {
        id: remountDocsProc
        command: ["pkexec", "systemctl", "restart", "mnt-network\\x2dstorage-documents.mount"]
        onExited: refresh()
    }

    Process {
        id: remountMediaProc
        command: ["pkexec", "systemctl", "restart", "mnt-network\\x2dstorage-media.mount"]
        onExited: refresh()
    }

    Process {
        id: remountAllProc
        command: ["pkexec", "systemctl", "restart", "mnt-network\\x2dstorage-documents.mount", "mnt-network\\x2dstorage-media.mount"]
        onExited: refresh()
    }

    Process {
        id: syncProc
        command: ["systemctl", "--user", "start", "network-storage-sync.service"]
        onExited: {
            syncing = false
            refresh()
        }
    }

    Component.onCompleted: {
        configProc.running = true
        refresh()
    }
}
