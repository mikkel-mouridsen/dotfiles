import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property int mountedCount: mainInstance?.mountedCount ?? 0
    readonly property int totalShares: mainInstance?.shares?.length ?? 0
    readonly property bool hasShares: totalShares > 0
    readonly property bool hasMounted: mountedCount > 0

    readonly property bool showBadge:
        pluginApi?.pluginSettings?.showBadge ??
        pluginApi?.manifest?.metadata?.defaultSettings?.showBadge ??
        true

    readonly property bool hideWhenEmpty:
        pluginApi?.pluginSettings?.hideWhenEmpty ??
        pluginApi?.manifest?.metadata?.defaultSettings?.hideWhenEmpty ??
        false

    readonly property bool shouldShow: !hideWhenEmpty || hasShares

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor ?? "none"
    readonly property color iconColor: Color.resolveColorKey(iconColorKey)

    visible: shouldShow

    icon: "server"
    tooltipText: mainInstance?.buildTooltip()
    tooltipDirection: BarService.getTooltipDirection(screen?.name)
    baseSize: Style.getCapsuleHeightForScreen(screen?.name)
    applyUiScale: false
    customRadius: Style.radiusL

    colorBg: hasMounted ? Color.mPrimary : Style.capsuleColor
    colorFg: hasMounted ? Color.mOnPrimary : root.iconColor !== "transparent" ? root.iconColor : Color.mOnSurface
    colorBgHover: Color.mHover
    colorFgHover: Color.mOnHover
    colorBorder: "transparent"
    colorBorderHover: "transparent"

    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    Rectangle {
        visible: hasMounted && showBadge
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
            text: mountedCount
            pointSize: Style.fontSizeXXS
            color: Color.mOnPrimary
            font.weight: Font.Bold
        }
    }

    onClicked: {
        if (mainInstance) mainInstance.refresh()
        if (pluginApi?.openPanel) pluginApi.openPanel(screen, root)
    }

    onRightClicked: {
        PanelService.showContextMenu(contextMenu, root, screen)
    }

    NPopupContextMenu {
        id: contextMenu
        model: [
            { "label": "Open",          "action": "open",         "icon": "apps" },
            { "label": "Refresh",       "action": "refresh",      "icon": "refresh" },
            { "label": "Mount all",     "action": "mount-all",    "icon": "plug-connected" },
            { "label": "Unmount all",   "action": "unmount-all",  "icon": "plug-connected-x" },
            { "label": "Settings",      "action": "settings",     "icon": "settings" }
        ]
        onTriggered: action => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)
            if (action === "open") {
                mainInstance?.refresh()
                if (pluginApi?.openPanel) pluginApi.openPanel(screen, root)
            } else if (action === "refresh") {
                mainInstance?.refresh()
            } else if (action === "mount-all") {
                mainInstance?.mountAll()
            } else if (action === "unmount-all") {
                mainInstance?.unmountAll()
            } else if (action === "settings") {
                if (pluginApi?.manifest) BarService.openPluginSettings(screen, pluginApi.manifest)
            }
        }
    }
}
