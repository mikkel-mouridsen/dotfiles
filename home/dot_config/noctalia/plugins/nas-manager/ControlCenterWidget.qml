import QtQuick
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

NIconButtonHot {
    id: root

    property var pluginApi: null
    property ShellScreen screen

    readonly property var mainInstance: pluginApi?.mainInstance

    icon: "server"
    tooltipText: mainInstance?.buildTooltip()

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
            { "label": "Open",         "action": "open",        "icon": "apps" },
            { "label": "Refresh",      "action": "refresh",     "icon": "refresh" },
            { "label": "Mount all",    "action": "mount-all",   "icon": "plug-connected" },
            { "label": "Unmount all",  "action": "unmount-all", "icon": "plug-connected-x" },
            { "label": "Settings",     "action": "settings",    "icon": "settings" }
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
