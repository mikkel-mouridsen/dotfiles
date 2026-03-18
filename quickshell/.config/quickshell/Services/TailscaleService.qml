pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property bool running: false
    property string currentIP: ""
    property string hostname: ""
    property string exitNode: ""
    property var peers: []
    property bool pollingEnabled: false

    function refresh() {
        if (!statusProc.running) statusProc.running = true
    }

    function toggleUp() {
        toggleProc.command = running
            ? ["tailscale", "down"]
            : ["tailscale", "up"]
        toggleProc.running = true
    }

    // Poll timer — only active when pollingEnabled
    Timer {
        interval: 5000
        running: pollingEnabled
        repeat: true
        onTriggered: refresh()
    }

    // Accumulator for JSON output
    property string _buffer: ""

    Process {
        id: statusProc
        command: ["tailscale", "status", "--json"]

        stdout: SplitParser {
            onRead: data => {
                _buffer += data + "\n"
            }
        }

        onRunningChanged: {
            if (running) {
                _buffer = ""
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                running = false
                currentIP = ""
                hostname = ""
                exitNode = ""
                peers = []
                return
            }

            try {
                let json = JSON.parse(_buffer)

                // Self node
                let self = json.Self || {}
                running = json.BackendState === "Running"
                hostname = self.HostName || ""
                currentIP = (self.TailscaleIPs && self.TailscaleIPs.length > 0)
                    ? self.TailscaleIPs[0] : ""

                // Exit node
                exitNode = ""
                let peerList = []
                let peerMap = json.Peer || {}
                for (let key in peerMap) {
                    let p = peerMap[key]
                    if (p.ExitNode) {
                        exitNode = p.HostName || ""
                    }
                    peerList.push({
                        name: p.HostName || p.DNSName || key,
                        os: p.OS || "",
                        online: p.Online || false,
                        exitNode: p.ExitNode || false,
                        ip: (p.TailscaleIPs && p.TailscaleIPs.length > 0)
                            ? p.TailscaleIPs[0] : ""
                    })
                }
                peers = peerList
            } catch (e) {
                console.warn("TailscaleService: failed to parse JSON:", e)
            }
        }
    }

    Process {
        id: toggleProc
        onExited: refresh()
    }

    Component.onCompleted: refresh()
}
