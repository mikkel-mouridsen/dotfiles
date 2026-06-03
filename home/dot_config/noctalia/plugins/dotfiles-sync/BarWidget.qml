import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

// Bar capsule: an icon that reflects sync state plus a count badge.
//   clean    -> cloud-check
//   ahead    -> cloud-up      + badge (local edits + unpushed commits)
//   behind   -> cloud-down    + badge (commits to pull)
//   diverged -> arrows-exchange
//   syncing  -> refresh (spinning)
//   error    -> alert-triangle
NIconButton {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property string syncState: mainInstance?.syncState ?? "clean"
    readonly property int pendingCount: mainInstance?.pendingCount ?? 0
    readonly property bool isError: syncState === "error"
    readonly property bool isClean: syncState === "clean"
    readonly property bool isSyncing: syncState === "syncing"
    readonly property bool showBadge: pendingCount > 0 && !isClean && !isSyncing && !isError

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor ?? "none"
    readonly property color iconColor: Color.resolveColorKey(iconColorKey)

    function iconForState(s) {
        switch (s) {
        case "syncing": return "refresh"
        case "error": return "alert-triangle"
        case "behind": return "cloud-download"
        case "ahead": return "cloud-upload"
        case "diverged": return "arrows-exchange"
        default: return "cloud-check"
        }
    }

    icon: iconForState(syncState)
    tooltipText: mainInstance?.buildTooltip()
    tooltipDirection: BarService.getTooltipDirection(screen?.name)
    baseSize: Style.getCapsuleHeightForScreen(screen?.name)
    applyUiScale: false
    customRadius: Style.radiusL

    colorBg: isError ? Color.mError
                     : (!isClean && !isSyncing) ? Color.mPrimary
                                                : Style.capsuleColor
    colorFg: isError ? Color.mOnError
                     : (!isClean && !isSyncing) ? Color.mOnPrimary
                                                : (root.iconColor !== "transparent" ? root.iconColor : Color.mOnSurface)
    colorBgHover: Color.mHover
    colorFgHover: Color.mOnHover
    colorBorder: "transparent"
    colorBorderHover: "transparent"

    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    // Spin the refresh icon while a pull/push is running.
    RotationAnimation on rotation {
        running: root.isSyncing
        from: 0; to: 360
        duration: 1000
        loops: Animation.Infinite
        onRunningChanged: if (!running) root.rotation = 0
    }

    Rectangle {
        visible: root.showBadge
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Style.marginXXS
        anchors.rightMargin: Style.marginXXS
        width: badgeText.implicitWidth + Style.marginS
        height: badgeText.implicitHeight + Style.marginXS
        radius: height / 2
        color: Color.mPrimary
        z: 1

        NText {
            id: badgeText
            anchors.centerIn: parent
            text: root.pendingCount
            pointSize: Style.fontSizeXXS
            color: Color.mOnPrimary
            font.weight: Font.Bold
        }
    }

    onClicked: {
        mainInstance?.refreshStatus()
        if (pluginApi?.openPanel) pluginApi.openPanel(screen, root)
    }

    onRightClicked: {
        PanelService.showContextMenu(contextMenu, root, screen)
    }

    NPopupContextMenu {
        id: contextMenu
        model: [
            { "label": "Open",     "action": "open",     "icon": "git-fork" },
            { "label": "Pull",     "action": "pull",     "icon": "cloud-download" },
            { "label": "Push",     "action": "push",     "icon": "cloud-upload" },
            { "label": "Refresh",  "action": "refresh",  "icon": "refresh" },
            { "label": "Settings", "action": "settings", "icon": "settings" }
        ]
        onTriggered: action => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)
            if (action === "open") {
                mainInstance?.refreshStatus()
                if (pluginApi?.openPanel) pluginApi.openPanel(screen, root)
            } else if (action === "pull") {
                mainInstance?.pull()
            } else if (action === "push") {
                mainInstance?.push()
            } else if (action === "refresh") {
                mainInstance?.refreshStatus()
                mainInstance?.fetch()
            } else if (action === "settings") {
                if (pluginApi?.manifest) BarService.openPluginSettings(screen, pluginApi.manifest)
            }
        }
    }
}
