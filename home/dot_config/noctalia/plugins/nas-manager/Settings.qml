import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginL

    property var pluginApi: null
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property var shares: []
    property int sharesRevision: 0

    property bool editShowBadge: cfg.showBadge ?? defaults.showBadge ?? true
    property bool editHideWhenEmpty: cfg.hideWhenEmpty ?? defaults.hideWhenEmpty ?? false
    property bool editShowNotifications: cfg.showNotifications ?? defaults.showNotifications ?? true
    property string editFileBrowser: cfg.fileBrowser || defaults.fileBrowser || "nautilus"
    property int editPollInterval: cfg.pollIntervalSec ?? defaults.pollIntervalSec ?? 5
    property string iconColor: cfg.iconColor ?? defaults.iconColor ?? "none"

    property real preferredWidth: 800 * Style.uiScaleRatio

    Component.onCompleted: loadShares()

    function loadShares() {
        var src = cfg.shares ?? defaults.shares
        if (!src || !Array.isArray(src)) src = []
        var copy = []
        for (var i = 0; i < src.length; i++) {
            copy.push({
                id:              src[i].id || ("share-" + Date.now() + "-" + i),
                name:            src[i].name || "",
                host:            src[i].host || "",
                share:           src[i].share || "",
                mountpoint:      src[i].mountpoint || "",
                username:        src[i].username || "",
                credentialsFile: src[i].credentialsFile || "",
                extraOptions:    src[i].extraOptions || "iocharset=utf8,vers=3.0",
                version:         src[i].version || "3.0"
            })
        }
        shares = copy
        sharesRevision++
    }

    function saveSettings() {
        if (!pluginApi) return
        var valid = []
        for (var i = 0; i < shares.length; i++) {
            var s = shares[i]
            // Keep any row the user has touched (name/host/share) so newly added
            // shares persist across settings reloads while still being editable.
            if ((s.name || "").trim() === ""
                && (s.host || "").trim() === ""
                && (s.share || "").trim() === "") continue
            valid.push({
                id:              s.id,
                name:            (s.name || "").trim() || (s.host + "/" + s.share),
                host:            (s.host || "").trim(),
                share:           (s.share || "").trim(),
                mountpoint:      (s.mountpoint || "").trim(),
                username:        (s.username || "").trim(),
                credentialsFile: (s.credentialsFile || "").trim(),
                extraOptions:    (s.extraOptions || "").trim(),
                version:         (s.version || "3.0").trim()
            })
        }
        pluginApi.pluginSettings.shares = valid
        pluginApi.pluginSettings.showBadge = root.editShowBadge
        pluginApi.pluginSettings.hideWhenEmpty = root.editHideWhenEmpty
        pluginApi.pluginSettings.showNotifications = root.editShowNotifications
        pluginApi.pluginSettings.fileBrowser = root.editFileBrowser
        pluginApi.pluginSettings.pollIntervalSec = root.editPollInterval
        pluginApi.pluginSettings.iconColor = root.iconColor
        pluginApi.saveSettings()
    }

    function addShare() {
        var copy = shares.slice()
        copy.push({
            id:              "share-" + Date.now(),
            name:            "New share",
            host:            "",
            share:           "",
            mountpoint:      "",
            username:        "",
            credentialsFile: "",
            extraOptions:    "iocharset=utf8,vers=3.0",
            version:         "3.0"
        })
        shares = copy
        sharesRevision++
        saveSettings()
    }

    function removeShare(index) {
        if (index < 0 || index >= shares.length) return
        var copy = shares.slice()
        copy.splice(index, 1)
        shares = copy
        sharesRevision++
        saveSettings()
    }

    // ───────── HEADER ─────────
    NText {
        text: "NAS Manager"
        pointSize: Style.fontSizeL
        font.bold: true
    }

    NText {
        text: "Configure CIFS/SMB shares. Mount/unmount goes through pkexec, so a polkit auth agent is required."
        color: Color.mOnSurfaceVariant
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }

    NDivider { Layout.fillWidth: true }

    // ───────── SHARES ─────────
    NText {
        text: "Shares"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NScrollView {
        id: sharesScroll
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(sharesColumn.implicitHeight, 500)
        showScrollbarWhenScrollable: true
        gradientColor: "transparent"

        ColumnLayout {
            id: sharesColumn
            width: sharesScroll.availableWidth
            spacing: Style.marginS

            Repeater {
                model: {
                    void root.sharesRevision
                    return root.shares.length
                }

                delegate: Rectangle {
                    id: shareDelegate
                    required property int index
                    readonly property var share: {
                        void root.sharesRevision
                        return index >= 0 && index < root.shares.length ? root.shares[index] : null
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: shareCol.implicitHeight + Style.marginM * 2
                    color: Color.mSurfaceVariant
                    radius: Style.radiusM

                    ColumnLayout {
                        id: shareCol
                        anchors {
                            left: parent.left; right: parent.right; top: parent.top
                            margins: Style.marginM
                        }
                        spacing: Style.marginS

                        // Header row: name + remove
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginS

                            NTextInput {
                                Layout.fillWidth: true
                                placeholderText: "Friendly name"
                                text: shareDelegate.share ? shareDelegate.share.name : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.name) {
                                        root.shares[shareDelegate.index].name = text
                                        saveDebounce.restart()
                                    }
                                }
                            }

                            NIconButton {
                                icon: "trash"
                                tooltipText: "Remove share"
                                onClicked: root.removeShare(shareDelegate.index)
                            }
                        }

                        // Host + share
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginS

                            NTextInput {
                                Layout.fillWidth: true
                                placeholderText: "Host (e.g. 192.168.1.68)"
                                text: shareDelegate.share ? shareDelegate.share.host : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.host) {
                                        root.shares[shareDelegate.index].host = text
                                        saveDebounce.restart()
                                    }
                                }
                            }

                            NTextInput {
                                Layout.fillWidth: true
                                placeholderText: "Share name (e.g. documents)"
                                text: shareDelegate.share ? shareDelegate.share.share : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.share) {
                                        root.shares[shareDelegate.index].share = text
                                        saveDebounce.restart()
                                    }
                                }
                            }
                        }

                        // Mountpoint
                        NTextInput {
                            Layout.fillWidth: true
                            placeholderText: "Mountpoint (e.g. /mnt/nas/documents)"
                            text: shareDelegate.share ? shareDelegate.share.mountpoint : ""
                            onTextChanged: {
                                if (shareDelegate.share && text !== shareDelegate.share.mountpoint) {
                                    root.shares[shareDelegate.index].mountpoint = text
                                    saveDebounce.restart()
                                }
                            }
                        }

                        // Username + credentials file
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginS

                            NTextInput {
                                Layout.fillWidth: true
                                placeholderText: "Username"
                                text: shareDelegate.share ? shareDelegate.share.username : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.username) {
                                        root.shares[shareDelegate.index].username = text
                                        saveDebounce.restart()
                                    }
                                }
                            }

                            NTextInput {
                                Layout.fillWidth: true
                                placeholderText: "Credentials file (optional)"
                                text: shareDelegate.share ? shareDelegate.share.credentialsFile : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.credentialsFile) {
                                        root.shares[shareDelegate.index].credentialsFile = text
                                        saveDebounce.restart()
                                    }
                                }
                            }
                        }

                        // Options + version
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginS

                            NTextInput {
                                Layout.fillWidth: true
                                placeholderText: "Extra mount options"
                                text: shareDelegate.share ? shareDelegate.share.extraOptions : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.extraOptions) {
                                        root.shares[shareDelegate.index].extraOptions = text
                                        saveDebounce.restart()
                                    }
                                }
                            }

                            NTextInput {
                                Layout.preferredWidth: 80
                                placeholderText: "SMB ver"
                                text: shareDelegate.share ? shareDelegate.share.version : ""
                                onTextChanged: {
                                    if (shareDelegate.share && text !== shareDelegate.share.version) {
                                        root.shares[shareDelegate.index].version = text
                                        saveDebounce.restart()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            NButton {
                Layout.fillWidth: true
                text: "Add share"
                icon: "plus"
                onClicked: root.addShare()
            }
        }
    }

    NDivider { Layout.fillWidth: true }

    // ───────── BEHAVIOR ─────────
    NText {
        text: "Behavior"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: "Notifications"
        description: "Show a toast on mount/unmount success or failure."
        checked: root.editShowNotifications
        onToggled: checked => {
            root.editShowNotifications = checked
            root.saveSettings()
        }
    }

    NComboBox {
        Layout.fillWidth: true
        label: "File browser"
        description: "Used when opening a mounted share from the panel."
        model: [
            { key: "nautilus", name: "nautilus" },
            { key: "dolphin",  name: "dolphin" },
            { key: "thunar",   name: "thunar" },
            { key: "xdg-open", name: "xdg-open" }
        ]
        currentKey: root.editFileBrowser
        onSelected: key => {
            root.editFileBrowser = key
            root.saveSettings()
        }
    }

    NDivider { Layout.fillWidth: true }

    // ───────── BAR ─────────
    NText {
        text: "Bar widget"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: "Hide when no shares are configured"
        checked: root.editHideWhenEmpty
        onToggled: checked => {
            root.editHideWhenEmpty = checked
            root.saveSettings()
        }
    }

    NToggle {
        Layout.fillWidth: true
        label: "Show mounted-count badge"
        checked: root.editShowBadge
        onToggled: checked => {
            root.editShowBadge = checked
            root.saveSettings()
        }
    }

    NColorChoice {
        currentKey: root.iconColor
        label: "Icon color"
        onSelected: key => {
            root.iconColor = key
            root.saveSettings()
        }
    }

    Item { Layout.fillHeight: true }

    // Debounce so we don't write on every keystroke
    Timer {
        id: saveDebounce
        interval: 600
        repeat: false
        onTriggered: root.saveSettings()
    }
}
