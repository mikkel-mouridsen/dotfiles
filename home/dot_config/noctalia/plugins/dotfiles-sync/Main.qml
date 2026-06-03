import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

// Business logic for the Dotfiles Sync plugin.
//
// Wraps chezmoi. The state is derived from two cheap, local signals:
//   * `chezmoi status`            -> files where your live config differs from
//                                     the repo source (things a Push would capture).
//   * `git rev-list ... HEAD...@u`-> commits ahead/behind the remote (set after a
//                                     periodic `git fetch`).
//
// Directions map onto buttons:
//   Pull  = chezmoi update      (git pull --ff-only + apply)
//   Push  = chezmoi re-add + git add -A + commit + push
//   Diff  = chezmoi diff
Item {
    id: root

    property var pluginApi: null

    // ----- derived state -----
    property int localChanges: 0      // count of `chezmoi status` entries
    property var changedFiles: []     // [{ code, path }]
    property int ahead: 0             // local commits not on remote
    property int behind: 0            // remote commits not local
    property bool busy: false         // a pull/push is running
    property string lastError: ""     // last operation error (cleared on success)
    property string lastDiff: ""      // cached `chezmoi diff` output
    property string sourcePath: ""    // chezmoi source dir (for Settings display)
    property string hostName: "machine"
    property var lastSync: null       // Date of last successful pull/push

    readonly property string chezmoiBin: pluginApi?.pluginSettings?.chezmoiPath || "chezmoi"
    readonly property int statusPollSec: pluginApi?.pluginSettings?.statusPollSec ?? 15
    readonly property int autoFetchMinutes: pluginApi?.pluginSettings?.autoFetchMinutes ?? 30
    readonly property bool showNotifications: pluginApi?.pluginSettings?.showNotifications ?? true

    // clean | ahead | behind | diverged | syncing | error
    readonly property string syncState: {
        if (busy) return "syncing"
        if (lastError) return "error"
        const out = ahead > 0 || localChanges > 0
        const incoming = behind > 0
        if (out && incoming) return "diverged"
        if (incoming) return "behind"
        if (out) return "ahead"
        return "clean"
    }

    // Count shown on the bar badge.
    readonly property int pendingCount: {
        if (syncState === "behind") return behind
        if (syncState === "diverged") return behind + ahead + localChanges
        return ahead + localChanges
    }

    Component.onCompleted: {
        hostProc.running = true
        sourcePathProc.running = true
        refreshStatus()
        fetchProc.running = true
    }

    // ===== IPC =====
    IpcHandler {
        target: "plugin:dotfiles-sync"
        function refresh() { root.refreshStatus(); root.fetch() }
        function pull() { root.pull() }
        function push() { root.push() }
        function diff() { root.loadDiff() }
    }

    // ===== TIMERS =====
    Timer {
        id: statusTimer
        interval: Math.max(5, root.statusPollSec) * 1000
        repeat: true
        running: true
        onTriggered: if (!root.busy) root.refreshStatus()
    }

    Timer {
        id: fetchTimer
        interval: Math.max(1, root.autoFetchMinutes) * 60 * 1000
        repeat: true
        running: true
        onTriggered: if (!root.busy) root.fetch()
    }

    // ===== READ-ONLY PROBES =====
    Process {
        id: hostProc
        command: ["sh", "-c", "hostname"]
        running: false
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                const h = String(stdout.text).trim()
                if (h.length > 0) root.hostName = h
            }
        }
    }

    Process {
        id: sourcePathProc
        command: [root.chezmoiBin, "source-path"]
        running: false
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) root.sourcePath = String(stdout.text).trim()
        }
    }

    // `chezmoi status` — local drift between live config and source.
    Process {
        id: statusProc
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            // exitStatus !== 0 means the process was terminated (e.g. a newer
            // refresh superseded this one) — that's not a real chezmoi error.
            if (exitStatus !== 0) return
            if (exitCode !== 0) {
                root.lastError = String(stderr.text).trim() || ("chezmoi status exit " + exitCode)
                return
            }
            root.lastError = ""   // status succeeded — clear any stale error
            const lines = String(stdout.text).split("\n")
            const files = []
            for (let i = 0; i < lines.length; i++) {
                const ln = lines[i]
                if (ln.trim().length === 0) continue
                // Format: two status chars, a space, then the path.
                files.push({ code: ln.substring(0, 2).trim(), path: ln.substring(3) })
            }
            root.changedFiles = files
            root.localChanges = files.length
        }
    }

    // `git fetch` then compute ahead/behind.
    Process {
        id: fetchProc
        command: [root.chezmoiBin, "git", "--", "fetch", "--quiet"]
        running: false
        onExited: exitCode => {
            // Even if fetch fails (offline), still try to read local ahead/behind.
            aheadBehindProc.running = true
        }
    }

    Process {
        id: aheadBehindProc
        command: [root.chezmoiBin, "git", "--", "rev-list", "--left-right", "--count", "HEAD...@{u}"]
        running: false
        stdout: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (exitStatus !== 0) return   // terminated, not a real result
            if (exitCode !== 0) {
                // No upstream configured / detached — treat as nothing to push/pull.
                root.ahead = 0
                root.behind = 0
                return
            }
            const parts = String(stdout.text).trim().split(/\s+/)
            if (parts.length >= 2) {
                root.ahead = parseInt(parts[0]) || 0
                root.behind = parseInt(parts[1]) || 0
            }
        }
    }

    // `chezmoi diff`
    Process {
        id: diffProc
        command: [root.chezmoiBin, "diff"]
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (exitStatus !== 0) return
            if (exitCode === 0) {
                root.lastDiff = String(stdout.text)
            } else {
                root.lastError = String(stderr.text).trim() || ("chezmoi diff exit " + exitCode)
            }
        }
    }

    // ===== MUTATING OPERATIONS =====
    // Pull: git pull --ff-only + apply, in one chezmoi command.
    Process {
        id: pullProc
        command: [root.chezmoiBin, "update", "--no-tty"]
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            root.busy = false
            if (exitStatus !== 0) return   // terminated (e.g. shell reload) — not a failure
            if (exitCode === 0) {
                root.lastError = ""
                root.lastSync = new Date()
                if (root.showNotifications) ToastService.showNotice("Dotfiles", "Pulled and applied")
            } else {
                root.lastError = String(stderr.text).trim() || ("pull exit " + exitCode)
                ToastService.showError("Dotfiles pull failed", root.lastError)
            }
            root.refreshStatus()
            root.fetch()
        }
    }

    // Push: capture live edits into source, commit if anything changed, push.
    // $1 = chezmoi binary, $2 = commit message
    readonly property string pushScript:
        'set -e\n' +
        'B="$1"; M="$2"\n' +
        '"$B" re-add\n' +
        '"$B" git -- add -A\n' +
        'if ! "$B" git -- diff --cached --quiet; then\n' +
        '  "$B" git -- commit -m "$M"\n' +
        'fi\n' +
        '"$B" git -- push\n'

    Process {
        id: pushProc
        running: false
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            root.busy = false
            if (exitStatus !== 0) return   // terminated (e.g. shell reload) — not a failure
            if (exitCode === 0) {
                root.lastError = ""
                root.lastSync = new Date()
                if (root.showNotifications) ToastService.showNotice("Dotfiles", "Pushed to remote")
            } else {
                root.lastError = String(stderr.text).trim() || ("push exit " + exitCode)
                ToastService.showError("Dotfiles push failed", root.lastError)
            }
            root.refreshStatus()
            root.fetch()
        }
    }

    // ===== PUBLIC API =====
    function refreshStatus() {
        // Don't restart an in-flight status: setting running=false would SIGTERM
        // it (exit 15) and the handler would misread that as a failure.
        if (statusProc.running) return
        statusProc.command = [root.chezmoiBin, "status"]
        statusProc.running = true
    }

    function fetch() {
        if (fetchProc.running || aheadBehindProc.running) return
        fetchProc.running = true
    }

    function loadDiff() {
        if (diffProc.running) return
        diffProc.running = true
    }

    function pull() {
        if (root.busy) return
        root.busy = true
        root.lastError = ""
        pullProc.running = true
    }

    function push() {
        if (root.busy) return
        root.busy = true
        root.lastError = ""
        const tmpl = pluginApi?.pluginSettings?.commitTemplate || "sync from {host}"
        const msg = tmpl.replace("{host}", root.hostName)
        pushProc.command = ["sh", "-c", root.pushScript, "--", root.chezmoiBin, msg]
        pushProc.running = true
    }

    function openDiffInTerminal() {
        const term = pluginApi?.pluginSettings?.terminal || "ghostty"
        Quickshell.execDetached([term, "-e", "sh", "-c", root.chezmoiBin + " diff | less -R"])
    }

    function lastSyncText() {
        if (!root.lastSync) return "never"
        const diffMs = Date.now() - root.lastSync.getTime()
        const m = Math.floor(diffMs / 60000)
        if (m < 1) return "just now"
        if (m < 60) return m + "m ago"
        const h = Math.floor(m / 60)
        if (h < 24) return h + "h ago"
        return Math.floor(h / 24) + "d ago"
    }

    function stateLabel() {
        switch (root.syncState) {
        case "syncing": return "Syncing…"
        case "error": return "Error"
        case "behind": return root.behind + " to pull"
        case "ahead": return (root.ahead + root.localChanges) + " to push"
        case "diverged": return "Diverged (" + root.behind + "↓ " + (root.ahead + root.localChanges) + "↑)"
        default: return "Up to date"
        }
    }

    function buildTooltip() {
        if (root.lastError) return "Dotfiles — " + root.lastError
        return "Dotfiles — " + stateLabel() + "  ·  last sync " + lastSyncText()
    }
}
