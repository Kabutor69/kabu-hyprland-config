import "../../"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    property bool active: false
    property var system
    property var battSystem
    property var expandedGroups: ({})
    
    readonly property var groups: {
        const src = root.system ? root.system.history : [];
        const byApp = {};
        const order = [];
        for (let i = 0; i < src.length; i++) {
            const notification = src[i];
            const appName = notification.appName || "Unknown";
            if (!byApp[appName]) {
                byApp[appName] = [];
                order.push(appName);
            }
            byApp[appName].push(notification);
        }
        return order.map((name) => {
            return {
                "appName": name,
                "items": byApp[name],
                "latest": byApp[name][0]
            };
        });
    }
    readonly property int totalCount: system ? system.history.length : 0

    signal closeRequested()

    width: parent ? parent.width : 360
    height: parent ? parent.height : 600

    function pulse() {
        flashAnim.restart();
    }

    function toggleGroup(appName) {
        const copy = Object.assign({}, expandedGroups);
        copy[appName] = !copy[appName];
        expandedGroups = copy;
    }

    function collapseGroup(appName) {
        const copy = Object.assign({}, expandedGroups);
        copy[appName] = false;
        expandedGroups = copy;
    }

    function clearGroup(appName) {
        if (!root.system) return;
        root.system.clearAppGroup(appName);
        root.collapseGroup(appName);
    }

    function imageSource(raw) {
        if (!raw) return "";
        if (raw.startsWith("/")) return "file://" + raw;
        if (raw.startsWith("file://") || raw.startsWith("http://") || raw.startsWith("https://") || raw.startsWith("image://"))
            return raw;
        return Quickshell.iconPath(raw);
    }

    function escapeRegex(s) {
        return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    }

    function openNotification(notification) {
        if (!notification) return;
        const needle = (notification.appName || notification.title || "").toLowerCase();
        if (needle.length > 1) {
            Hyprland.refreshToplevels();
            const wins = Hyprland.toplevels.values;
            for (let i = 0; i < wins.length; i++) {
                const w = wins[i];
                const rawClass = w.wmClass || w.class || "";
                const windowClass = rawClass.toLowerCase();
                const windowTitle = (w.title || "").toLowerCase();
                const classMatch = windowClass.length > 0 && (windowClass.includes(needle) || needle.includes(windowClass));
                const titleMatch = windowTitle.length > 0 && windowTitle.includes(needle);
                if (classMatch || titleMatch) {
                    if (rawClass) {
                        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ window = 'class:^(" + root.escapeRegex(rawClass) + ")$' })"]);
                    } else if (w.address) {
                        const address = w.address.startsWith("0x") ? w.address : "0x" + w.address;
                        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ window = 'address:" + address + "' })"]);
                    }
                    break;
                }
            }
        }
        if (root.system) root.system.removeFromHistory(notification.id);
    }

    opacity: active ? 1 : 0
    scale: active ? 1 : 0.98
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
    }

    Behavior on scale {
        NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: root; property: "scale"; to: 1.01; duration: 60; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 16

        
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28

            Text {
                id: dateText
                text: Qt.formatDate(new Date(), "dddd, MMM d")
                color: Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }

            Item { Layout.fillWidth: true }

            
            Rectangle {
                id: batteryIcon
                property bool charging: root.battSystem && root.battSystem.isCharging
                property int level: root.battSystem ? Math.round(root.battSystem.batteryLevel) : 100

                implicitWidth: 48
                implicitHeight: 22
                radius: Radius.capsule
                color: Colors.tileBg
                border.color: Colors.tileBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: batteryIcon.charging ? "\uf0e7" : (batteryIcon.level <= 20 ? "\uf244" : "\uf240")
                        color: batteryIcon.charging ? Colors.green : (batteryIcon.level <= 20 ? Colors.red : Colors.textSecondary)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    Text {
                        text: batteryIcon.level + "%"
                        color: Colors.textSecondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            
            ColumnLayout {
                anchors.centerIn: parent
                visible: root.totalCount === 0
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\uf0f3"
                    color: Colors.disabled
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 32
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No Notifications"
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }

            ListView {
                id: notificationList
                anchors.fill: parent
                visible: root.totalCount > 0
                clip: true
                spacing: 12
                model: root.groups

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
                    NumberAnimation { property: "y"; from: -10; duration: 140; easing.type: Easing.OutQuad }
                }

                remove: Transition {
                    NumberAnimation { property: "opacity"; to: 0; duration: 120; easing.type: Easing.OutQuad }
                }

                delegate: Item {
                    id: groupDelegate
                    required property var modelData
                    readonly property bool expanded: !!root.expandedGroups[modelData.appName]
                    readonly property int previewCount: Math.min(3, modelData.items.length)

                    width: notificationList.width
                    height: expanded ? expandedContent.implicitHeight : stackContent.height

                    Behavior on height {
                        NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
                    }

                    
                    Item {
                        id: stackContent
                        width: parent.width
                        height: groupDelegate.previewCount > 1 ? 72 + (groupDelegate.previewCount - 1) * 6 : 72
                        visible: opacity > 0
                        opacity: groupDelegate.expanded ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Repeater {
                            model: groupDelegate.previewCount

                            delegate: Rectangle {
                                id: card
                                required property int index

                                width: parent.width - (index * 10)
                                height: 72
                                x: index * 5
                                y: index * 6
                                z: groupDelegate.previewCount - index
                                radius: Radius.card

                                color: index === 0 ? Colors.tileBg : Qt.rgba(0.08, 0.08, 0.1, 0.7 - (index * 0.2))
                                border.color: index === 0 ? Colors.tileBorder : Qt.rgba(1, 1, 1, 0.05)
                                border.width: 1

                                Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12
                                    visible: index === 0

                                    NotifIcon {
                                        Layout.preferredWidth: 44
                                        Layout.preferredHeight: 44
                                        iconSource: groupDelegate.modelData.latest.image || groupDelegate.modelData.latest.appIcon || ""
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: groupDelegate.modelData.appName
                                                color: Colors.text
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                visible: groupDelegate.modelData.items.length > 1
                                                implicitWidth: countText.implicitWidth + 10
                                                implicitHeight: 16
                                                radius: Radius.badge
                                                color: Colors.hover

                                                Text {
                                                    id: countText
                                                    anchors.centerIn: parent
                                                    text: "+" + (groupDelegate.modelData.items.length - 1)
                                                    color: Colors.text
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                }
                                            }
                                        }

                                        Text {
                                            text: groupDelegate.modelData.latest.title || groupDelegate.modelData.latest.body || ""
                                            color: Colors.textSecondary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: if (index === 0) card.border.color = Colors.hover
                                    onExited: if (index === 0) card.border.color = Colors.tileBorder
                                    onClicked: root.toggleGroup(groupDelegate.modelData.appName)
                                }
                            }
                        }
                    }

                    
                    ColumnLayout {
                        id: expandedContent
                        width: parent.width
                        visible: opacity > 0
                        spacing: 8
                        opacity: groupDelegate.expanded ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
                        }

                        
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Radius.button
                            color: Colors.elevated
                            border.color: Colors.tileBorder
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 6
                                spacing: 8

                                NotifIcon {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    iconSource: groupDelegate.modelData.latest.appIcon || groupDelegate.modelData.latest.image || ""
                                }

                                Text {
                                    text: groupDelegate.modelData.appName
                                    color: Colors.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                ActionButton {
                                    glyph: "\uf00d"
                                    tooltipText: "Clear Group"
                                    onClicked: root.clearGroup(groupDelegate.modelData.appName)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.rightMargin: 36
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleGroup(groupDelegate.modelData.appName)
                            }
                        }

                        
                        Repeater {
                            model: groupDelegate.modelData.items

                            delegate: Rectangle {
                                id: notificationCard
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: notificationBody.text !== "" ? 76 : 56
                                radius: Radius.button
                                color: Colors.tileBg
                                border.color: cardMouse.containsMouse ? Colors.hover : Colors.tileBorder
                                border.width: 1

                                Behavior on opacity {
                                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    NotifIcon {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        iconSource: notificationCard.modelData.image || notificationCard.modelData.appIcon || ""
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: notificationCard.modelData.title || groupDelegate.modelData.appName
                                            color: Colors.text
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            id: notificationBody
                                            text: (notificationCard.modelData.body || "").replace(/\s+/g, " ").trim()
                                            visible: text !== ""
                                            color: Colors.textSecondary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            Layout.fillWidth: true
                                            maximumLineCount: 2
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    
                                    ActionButton {
                                        glyph: "\uf00d"
                                        tooltipText: "Dismiss"
                                        onClicked: {
                                            notificationCard.opacity = 0;
                                            dismissTimer.start();
                                        }

                                        Timer {
                                            id: dismissTimer
                                            interval: 80
                                            repeat: false
                                            onTriggered: {
                                                if (root.system) root.system.removeFromHistory(notificationCard.modelData.id);
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: cardMouse
                                    anchors.fill: parent
                                    anchors.rightMargin: 36
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        notificationCard.opacity = 0;
                                        openTimer.start();
                                    }

                                    Timer {
                                        id: openTimer
                                        interval: 80
                                        repeat: false
                                        onTriggered: root.openNotification(notificationCard.modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: 18
            // visible: root.totalCount > 0

            Rectangle {
                height: 18
                width: clearAllText.implicitWidth + 12
                radius: Radius.small
                color: clearAllHover.containsMouse ? Colors.red : Colors.transparent

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: clearAllText
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: clearAllHover.containsMouse ? Colors.bg : Colors.red
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    font.bold: true
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: clearAllHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.system) root.system.clearAll();
                        root.expandedGroups = ({});
                    }
                }
            }

            Item { width: parent.width - clearAllText.implicitWidth - hintText.implicitWidth - 12; height: 1 }

            Text {
                id: hintText
                anchors.verticalCenter: parent.verticalCenter
                text: "Esc Close"
                color: Colors.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
                renderType: Text.NativeRendering
            }

        }
    }

    
    component NotifIcon: Rectangle {
        id: iconBox
        property string iconSource: ""

        radius: Radius.medium
        color: Colors.tileBg
        border.color: Colors.tileBorder
        border.width: 1

        Image {
            anchors.fill: parent
            anchors.margins: 4
            source: root.imageSource(iconBox.iconSource)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: parent.children[0].status !== Image.Ready
            text: "\uf0f3"
            color: Colors.textSecondary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }
    }

    
    component ActionButton: Rectangle {
        id: button
        property string glyph: ""
        property string tooltipText: ""

        signal clicked()

        implicitWidth: 26
        implicitHeight: 26
        radius: Radius.small
        color: buttonMouse.containsMouse ? Colors.hover : Colors.transparent

        Text {
            anchors.centerIn: parent
            text: button.glyph
            color: buttonMouse.containsMouse ? Colors.text : Colors.textSecondary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}
