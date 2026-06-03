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
    readonly property var mainInstance: pluginApi?.mainInstance

    property real preferredWidth: 800 * Style.uiScaleRatio

    property string editChezmoiPath: cfg.chezmoiPath || defaults.chezmoiPath || "chezmoi"
    property string editCommitTemplate: cfg.commitTemplate || defaults.commitTemplate || "sync from {host}"
    property string editTerminal: cfg.terminal || defaults.terminal || "ghostty"
    property int editStatusPollSec: cfg.statusPollSec ?? defaults.statusPollSec ?? 15
    property int editAutoFetchMinutes: cfg.autoFetchMinutes ?? defaults.autoFetchMinutes ?? 30
    property bool editShowNotifications: cfg.showNotifications ?? defaults.showNotifications ?? true
    property bool editOpenDiffInTerminal: cfg.openDiffInTerminal ?? defaults.openDiffInTerminal ?? false
    property string iconColor: cfg.iconColor ?? defaults.iconColor ?? "none"

    function saveSettings() {
        if (!pluginApi) return
        pluginApi.pluginSettings.chezmoiPath = (root.editChezmoiPath || "chezmoi").trim()
        pluginApi.pluginSettings.commitTemplate = root.editCommitTemplate || "sync from {host}"
        pluginApi.pluginSettings.terminal = (root.editTerminal || "ghostty").trim()
        pluginApi.pluginSettings.statusPollSec = Math.max(5, root.editStatusPollSec)
        pluginApi.pluginSettings.autoFetchMinutes = Math.max(1, root.editAutoFetchMinutes)
        pluginApi.pluginSettings.showNotifications = root.editShowNotifications
        pluginApi.pluginSettings.openDiffInTerminal = root.editOpenDiffInTerminal
        pluginApi.pluginSettings.iconColor = root.iconColor
        pluginApi.saveSettings()
    }

    // ───────── Header ─────────
    NText {
        text: "Dotfiles Sync"
        pointSize: Style.fontSizeL
        font.bold: true
    }
    NText {
        text: "Wraps chezmoi. Pull = chezmoi update (git pull + apply). Push = chezmoi re-add + commit + push."
        color: Color.mOnSurfaceVariant
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }

    NText {
        visible: (mainInstance?.sourcePath ?? "") !== ""
        text: "Source: " + (mainInstance?.sourcePath ?? "")
        pointSize: Style.fontSizeXS
        color: Color.mOnSurfaceVariant
        Layout.fillWidth: true
        elide: Text.ElideMiddle
    }

    NDivider { Layout.fillWidth: true }

    // ───────── Sync behavior ─────────
    NText {
        text: "Sync"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        NText { text: "Commit message"; Layout.preferredWidth: 160; color: Color.mOnSurface }
        NTextInput {
            Layout.fillWidth: true
            placeholderText: "sync from {host}"
            text: root.editCommitTemplate
            onTextChanged: {
                if (text !== root.editCommitTemplate) { root.editCommitTemplate = text; saveDebounce.restart() }
            }
        }
    }
    NText {
        text: "{host} is replaced with this machine's hostname."
        pointSize: Style.fontSizeXS
        color: Color.mOnSurfaceVariant
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        NText { text: "Status poll (sec)"; Layout.preferredWidth: 160; color: Color.mOnSurface }
        NTextInput {
            Layout.preferredWidth: 100
            text: String(root.editStatusPollSec)
            onTextChanged: {
                const v = parseInt(text)
                if (!isNaN(v) && v !== root.editStatusPollSec) { root.editStatusPollSec = v; saveDebounce.restart() }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        NText { text: "Auto-fetch (min)"; Layout.preferredWidth: 160; color: Color.mOnSurface }
        NTextInput {
            Layout.preferredWidth: 100
            text: String(root.editAutoFetchMinutes)
            onTextChanged: {
                const v = parseInt(text)
                if (!isNaN(v) && v !== root.editAutoFetchMinutes) { root.editAutoFetchMinutes = v; saveDebounce.restart() }
            }
        }
    }

    NToggle {
        Layout.fillWidth: true
        label: "Notifications"
        description: "Show a toast after pull/push succeeds or fails."
        checked: root.editShowNotifications
        onToggled: checked => { root.editShowNotifications = checked; root.saveSettings() }
    }

    NDivider { Layout.fillWidth: true }

    // ───────── Advanced ─────────
    NText {
        text: "Advanced"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        NText { text: "chezmoi binary"; Layout.preferredWidth: 160; color: Color.mOnSurface }
        NTextInput {
            Layout.fillWidth: true
            placeholderText: "chezmoi"
            text: root.editChezmoiPath
            onTextChanged: {
                if (text !== root.editChezmoiPath) { root.editChezmoiPath = text; saveDebounce.restart() }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        NText { text: "Terminal"; Layout.preferredWidth: 160; color: Color.mOnSurface }
        NTextInput {
            Layout.fillWidth: true
            placeholderText: "ghostty"
            text: root.editTerminal
            onTextChanged: {
                if (text !== root.editTerminal) { root.editTerminal = text; saveDebounce.restart() }
            }
        }
    }

    NColorChoice {
        currentKey: root.iconColor
        label: "Icon color"
        onSelected: key => { root.iconColor = key; root.saveSettings() }
    }

    Item { Layout.fillHeight: true }

    Timer {
        id: saveDebounce
        interval: 600
        repeat: false
        onTriggered: root.saveSettings()
    }
}
