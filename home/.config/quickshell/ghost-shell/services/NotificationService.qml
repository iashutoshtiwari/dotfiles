pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    property int unreadCount: 0

    // Set to true by ActionCenter while it is open.
    // When true: new notifications do not increment unreadCount
    // (they are already visible in the drawer), and toasts are suppressed.
    property bool actionCenterOpen: false

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
            // Keep notification in tracked history regardless of DND or AC state
            notif.tracked = true;

            // Only increment unread if the action center is not currently open.
            // When the drawer is open the user is already looking at notifications.
            if (!root.actionCenterOpen) {
                root.unreadCount++;
            }

            // Trigger visual toast banner if DND is off AND action center is closed.
            // When the action center is open, the notification appears in-drawer so
            // a duplicate toast would be redundant.
            if (!root.dnd && !root.actionCenterOpen) {
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
