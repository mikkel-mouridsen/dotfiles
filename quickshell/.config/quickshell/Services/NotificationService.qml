pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    property bool doNotDisturb: false
    property int unreadCount: 0

    signal newNotification(var notification)

    readonly property ListModel history: ListModel {}

    NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: true

        onNotification: function(notification) {
            notification.tracked = true

            // Add to history (newest first)
            history.insert(0, {
                notifId: notification.id,
                appName: notification.appName ?? "",
                appIcon: notification.appIcon ?? "",
                summary: notification.summary ?? "",
                body: notification.body ?? "",
                urgency: notification.urgency,
                image: notification.image ?? "",
                timestamp: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
            })

            // Cap at 50
            while (history.count > 50) {
                history.remove(history.count - 1)
            }

            unreadCount++

            if (!doNotDisturb) {
                newNotification(notification)
            }
        }
    }

    function clearAll() {
        history.clear()
        unreadCount = 0
    }

    function dismiss(index) {
        if (index >= 0 && index < history.count) {
            history.remove(index)
        }
    }
}
