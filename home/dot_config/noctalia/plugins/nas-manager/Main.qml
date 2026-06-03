import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property var shares: []
    property bool loading: false

    // Pending mount: a mount that returned exit 42 (no keyring entry).
    // Cleared after password is provided or user cancels.
    property string pendingShareId: ""
    property string pendingShareName: ""
    property string pendingShareUsername: ""

    signal passwordNeeded(string shareId, string shareName, string username)

    readonly property int mountedCount: {
        let c = 0
        for (let i = 0; i < shares.length; i++) {
            if (shares[i].isMounted) c++
        }
        return c
    }

    readonly property var configuredShares: pluginApi?.pluginSettings?.shares ?? []
    readonly property int pollIntervalSec: pluginApi?.pluginSettings?.pollIntervalSec ?? 5
    readonly property bool showNotifications: pluginApi?.pluginSettings?.showNotifications ?? true
    readonly property string fileBrowser: pluginApi?.pluginSettings?.fileBrowser || "nautilus"

    Component.onCompleted: refresh()
    onConfiguredSharesChanged: refresh()

    // ===== IPC =====
    IpcHandler {
        target: "plugin:nas-manager"
        function refresh() { root.refresh() }
        function mountAll() { root.mountAll() }
        function unmountAll() { root.unmountAll() }
    }

    // ===== STATUS POLLING =====
    Process {
        id: mountsRead
        command: ["cat", "/proc/mounts"]
        running: false
        stdout: StdioCollector {}
        onExited: exitCode => {
            root.loading = false
            if (exitCode === 0) internal.applyMountStatus(String(stdout.text))
        }
    }

    Timer {
        id: pollTimer
        interval: Math.max(2, root.pollIntervalSec) * 1000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Timer {
        id: dfDebounce
        interval: 800
        repeat: false
        onTriggered: { dfQuery.running = false; dfQuery.running = true }
    }

    Process {
        id: dfQuery
        command: ["df", "--output=target,pcent,used,avail", "-h"]
        running: false
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) internal.applyDfOutput(String(stdout.text))
        }
    }

    // ===== ACTIONS =====
    // mountProc: runs the shell script that looks up keyring and mounts.
    Process {
        id: mountProc
        property string shareId: ""
        property string shareName: ""
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                if (root.showNotifications) ToastService.showNotice("NAS mounted", mountProc.shareName)
                refreshDebounce.restart()
            } else if (exitCode === 42) {
                // No keyring entry — ask the user.
                const s = root.findShare(mountProc.shareId)
                root.pendingShareId = mountProc.shareId
                root.pendingShareName = mountProc.shareName
                root.pendingShareUsername = s ? s.username : ""
                root.passwordNeeded(mountProc.shareId, mountProc.shareName, root.pendingShareUsername)
            } else {
                const err = String(stderr.text).trim() || String(stdout.text).trim() || ("exit " + exitCode)
                ToastService.showError("Mount failed: " + mountProc.shareName, err)
                refreshDebounce.restart()
            }
        }
    }

    Process {
        id: unmountProc
        property string shareId: ""
        property string shareName: ""
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                if (root.showNotifications) ToastService.showNotice("NAS unmounted", unmountProc.shareName)
            } else {
                const err = String(stderr.text).trim() || ("exit " + exitCode)
                ToastService.showError("Unmount failed: " + unmountProc.shareName, err)
            }
            refreshDebounce.restart()
        }
    }

    // storePwdProc: writes a password to the keyring then triggers a retry of the pending mount.
    Process {
        id: storePwdProc
        property string shareId: ""
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                // Password is now in the keyring; rerun the original mount.
                if (root.showNotifications) ToastService.showNotice("Password saved", storePwdProc.shareId)
                root.mountShare(storePwdProc.shareId)
            } else {
                const err = String(stderr.text).trim() || ("exit " + exitCode)
                ToastService.showError("Could not save password", err)
            }
            root.pendingShareId = ""
            root.pendingShareName = ""
            root.pendingShareUsername = ""
        }
    }

    Process {
        id: forgetPwdProc
        property string shareName: ""
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                if (root.showNotifications) ToastService.showNotice("Password forgotten", forgetPwdProc.shareName)
            } else {
                const err = String(stderr.text).trim() || ("exit " + exitCode)
                ToastService.showError("Could not forget password", err)
            }
        }
    }

    Timer {
        id: refreshDebounce
        interval: 500
        repeat: false
        onTriggered: root.refresh()
    }

    // ===== HELPERS =====
    QtObject {
        id: internal

        function buildShareList() {
            const list = []
            const configured = root.configuredShares || []
            for (let i = 0; i < configured.length; i++) {
                const s = configured[i] || {}
                list.push({
                    id:              s.id || ("share-" + i),
                    name:            s.name || (s.host + "/" + s.share),
                    host:            s.host || "",
                    share:           s.share || "",
                    mountpoint:      s.mountpoint || "",
                    username:        s.username || "",
                    credentialsFile: s.credentialsFile || "",
                    extraOptions:    s.extraOptions || "iocharset=utf8,vers=3.0",
                    version:         s.version || "3.0",
                    isMounted:       false,
                    source:          "",
                    usedPercent:     0,
                    usedSize:        "",
                    freeSize:        ""
                })
            }
            return list
        }

        function applyMountStatus(text) {
            const next = internal.buildShareList()

            // Carry over usage figures from the previous snapshot so the usage
            // bar doesn't blink off between this poll and the next df result.
            const prevUsage = {}
            for (let p = 0; p < root.shares.length; p++) {
                const ps = root.shares[p]
                if (ps.mountpoint) {
                    prevUsage[ps.mountpoint] = {
                        usedPercent: ps.usedPercent,
                        usedSize:    ps.usedSize,
                        freeSize:    ps.freeSize
                    }
                }
            }

            const lines = text.split("\n")
            for (let l = 0; l < lines.length; l++) {
                const parts = lines[l].split(/\s+/)
                if (parts.length < 3) continue
                const src = parts[0], mp = parts[1], ty = parts[2]
                if (ty !== "cifs" && ty !== "smb3") continue
                for (let i = 0; i < next.length; i++) {
                    if (next[i].mountpoint === mp) {
                        next[i].isMounted = true
                        next[i].source = src
                    }
                }
            }

            for (let i = 0; i < next.length; i++) {
                if (next[i].isMounted && prevUsage[next[i].mountpoint]) {
                    const u = prevUsage[next[i].mountpoint]
                    next[i].usedPercent = u.usedPercent
                    next[i].usedSize = u.usedSize
                    next[i].freeSize = u.freeSize
                }
            }

            root.shares = next
            root.sharesChanged()
            dfDebounce.restart()
        }

        function applyDfOutput(text) {
            const lines = text.split("\n")
            const usage = {}
            for (let i = 1; i < lines.length; i++) {
                const p = lines[i].trim().split(/\s+/)
                if (p.length >= 4) usage[p[0]] = { pcent: parseInt(p[1]) || 0, used: p[2] || "", avail: p[3] || "" }
            }
            const updated = root.shares.map(s => {
                if (s.isMounted && usage[s.mountpoint]) {
                    const u = usage[s.mountpoint]
                    return Object.assign({}, s, { usedPercent: u.pcent, usedSize: u.used, freeSize: u.avail })
                }
                return s
            })
            root.shares = updated
            root.sharesChanged()
        }

        function extraOptsWithIds(extra) {
            const parts = []
            if (extra && extra.length > 0) parts.push(extra)
            parts.push("uid=" + uidQuery.uid)
            parts.push("gid=" + uidQuery.gid)
            return parts.join(",")
        }
    }

    QtObject {
        id: uidQuery
        property int uid: 1000
        property int gid: 1000
    }

    Process {
        id: idLookup
        command: ["sh", "-c", "echo $(id -u),$(id -g)"]
        running: true
        stdout: StdioCollector {}
        onExited: {
            const parts = String(stdout.text).trim().split(",")
            if (parts.length === 2) {
                uidQuery.uid = parseInt(parts[0]) || 1000
                uidQuery.gid = parseInt(parts[1]) || 1000
            }
        }
    }

    // ===== PUBLIC API =====
    function refresh() {
        root.loading = true
        mountsRead.running = false
        mountsRead.running = true
    }

    function findShare(id) {
        for (let i = 0; i < shares.length; i++) {
            if (shares[i].id === id) return shares[i]
        }
        return null
    }

    function mountShare(id) {
        const s = findShare(id)
        if (!s || mountProc.running) return
        if (!s.host || !s.share || !s.mountpoint) {
            ToastService.showError("Mount failed", "Share is missing host/share/mountpoint")
            return
        }
        if (!s.username) {
            ToastService.showError("Mount failed", "Share has no username configured")
            return
        }

        const src = "//" + s.host + "/" + s.share
        const opts = "vers=" + (s.version || "3.0") + "," + internal.extraOptsWithIds(s.extraOptions)

        // The script:
        //   1. mktemp a cred file in /dev/shm (tmpfs, never hits disk)
        //   2. fetch password from the user's keyring (Secret Service)
        //   3. if missing → exit 42 (Main.qml will prompt)
        //   4. write the cred file
        //   5. pkexec mount, then erase the cred file regardless of outcome
        //
        // Positional args:    $1=id   $2=username   $3=mountpoint   $4=//host/share   $5=options
        const script =
            'set -u\n' +
            'TMP=$(mktemp -p /dev/shm nas-XXXXXX.cred)\n' +
            'chmod 600 "$TMP"\n' +
            'cleanup() { rm -f "$TMP"; }\n' +
            'trap cleanup EXIT\n' +
            'PW=$(secret-tool lookup service nas-manager share "$1" 2>/dev/null || true)\n' +
            'if [ -z "$PW" ]; then exit 42; fi\n' +
            'printf "username=%s\\npassword=%s\\n" "$2" "$PW" > "$TMP"\n' +
            'pkexec sh -c \'mkdir -p "$1" && mount -t cifs "$2" "$1" -o credentials="$3","$4"\' nas-manager "$3" "$4" "$TMP" "$5"\n'

        mountProc.shareId = s.id
        mountProc.shareName = s.name
        mountProc.command = ["sh", "-c", script, "--", s.id, s.username, s.mountpoint, src, opts]
        mountProc.running = true
    }

    function unmountShare(id) {
        const s = findShare(id)
        if (!s || unmountProc.running) return
        unmountProc.shareId = s.id
        unmountProc.shareName = s.name
        unmountProc.command = ["pkexec", "umount", s.mountpoint]
        unmountProc.running = true
    }

    // Called by the password popup. Stores password in keyring under
    // service=nas-manager, share=<id>, then retries the mount.
    function savePasswordAndMount(id, password) {
        if (!id || !password) return
        const s = findShare(id)
        const label = s ? ("NAS: " + s.name) : ("NAS: " + id)
        // secret-tool reads password from stdin; we pipe it inside the shell so the
        // password is only briefly visible in /proc/<pid>/cmdline of the shell wrapper.
        // After this, future mounts read it from the keyring with no password in args.
        const script = 'printf "%s" "$2" | secret-tool store --label="$1" service nas-manager share "$3"'
        storePwdProc.shareId = id
        storePwdProc.command = ["sh", "-c", script, "--", label, password, id]
        storePwdProc.running = true
    }

    function forgetPassword(id) {
        const s = findShare(id)
        if (!s) return
        forgetPwdProc.shareName = s.name
        forgetPwdProc.command = ["secret-tool", "clear", "service", "nas-manager", "share", id]
        forgetPwdProc.running = true
    }

    function cancelPasswordPrompt() {
        pendingShareId = ""
        pendingShareName = ""
        pendingShareUsername = ""
    }

    function mountAll() {
        for (let i = 0; i < shares.length; i++) {
            if (!shares[i].isMounted) mountShare(shares[i].id)
        }
    }

    function unmountAll() {
        for (let i = 0; i < shares.length; i++) {
            if (shares[i].isMounted) unmountShare(shares[i].id)
        }
    }

    function openInFileBrowser(mountpoint) {
        Quickshell.execDetached([root.fileBrowser || "nautilus", mountpoint])
    }

    function buildTooltip() {
        const total = shares.length
        if (total === 0) return "NAS Manager — no shares configured"
        if (mountedCount === 0) return "NAS Manager — " + total + " share" + (total === 1 ? "" : "s") + ", none mounted"
        return "NAS Manager — " + mountedCount + "/" + total + " mounted"
    }
}
