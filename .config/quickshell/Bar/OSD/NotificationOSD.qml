import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../"

Item {
    id: notifOsd

    property string notifTitle: ""
    property string notifBody: ""
    property string notifAppIcon: ""
    property string notifAppName: ""
    property string notifImage: ""
    property int notifUrgency: 1

    property var history: []
    property int nextId: 1

    signal notificationReceived()

    function removeFromHistory(id) {
        const entry = history.find(e => e.id === id)
        if (entry && entry.rawNotification) {
            try { entry.rawNotification.dismiss() } catch (e) {}
        }
        history = history.filter(e => e.id !== id)
        historyChanged()
    }

    function clearAppGroup(appName) {
        const toRemove = history.filter(e => e.appName === appName)
        for (let i = 0; i < toRemove.length; i++) {
            if (toRemove[i].rawNotification) {
                try { toRemove[i].rawNotification.dismiss() } catch (e) {}
            }
        }
        history = history.filter(e => e.appName !== appName)
        historyChanged()
    }

    function clearAll() {
        for (let i = 0; i < history.length; i++) {
            if (history[i].rawNotification) {
                try { history[i].rawNotification.dismiss() } catch (e) {}
            }
        }
        history = []
        historyChanged()
    }

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: (notification) => {
            notifOsd.notifTitle = notification.summary || ""
            notifOsd.notifBody = notification.body || ""
            notifOsd.notifAppIcon = notification.appIcon || ""
            notifOsd.notifAppName = notification.appName || ""
            notifOsd.notifImage = notification.image || ""
            notifOsd.notifUrgency = notification.urgency !== undefined ? notification.urgency : 1

            
            
            
            
            notification.tracked = true

            const entry = {
                id: notifOsd.nextId++,
                title: notification.summary || "",
                body: notification.body || "",
                appIcon: notification.appIcon || "",
                appName: notification.appName || "Unknown",
                image: notification.image || "",
                urgency: notification.urgency !== undefined ? notification.urgency : 1,
                timestamp: Date.now(),
                rawNotification: notification
            }

            const updated = notifOsd.history.slice()
            updated.unshift(entry)
            if (updated.length > 50) updated.length = 50
            notifOsd.history = updated
            notifOsd.historyChanged()

            if (!DndState.enabled) {
                notifOsd.notificationReceived()
            }
        }
    }
}
