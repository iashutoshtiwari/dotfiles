pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    property int unreadCount: 0

    // Toasts signal for transient popup banners
    signal toastRequested(var notif)

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notif => {
            // Keep notification in tracked history
            notif.tracked = true;
            root.unreadCount++;

            // Trigger visual toast banner if DND is inactive
            if (!root.dnd) {
                root.toastRequested(notif);
            }
        }
    }

    readonly property alias trackedNotifications: server.trackedNotifications

    function toggleDnd(): void {
        dnd = !dnd;
    }

    function clearAll(): void {
        if (!server || !server.trackedNotifications)
            return;

        const list = server.trackedNotifications.values;
        for (let i = list.length - 1; i >= 0; i--) {
            if (list[i]) {
                list[i].dismiss();
            }
        }
        unreadCount = 0;
    }

    function dismiss(notif): void {
        if (notif) {
            notif.dismiss();
            if (unreadCount > 0)
                unreadCount--;
        }
    }

    function markAllRead(): void {
        unreadCount = 0;
    }
}
