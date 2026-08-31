import "../../"
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

Item {
    id: root

    property bool active: false
    readonly property int count: SystemTray.items ? SystemTray.items.values.length : 0
    readonly property real contentHeight: trayList.contentHeight

    signal menuRequested(var menu)
    signal closeRequested()

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    function pulse() {
        flashAnim.restart()
    }

    function escapeRegex(s) {
        return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    }

    function focusOrOpen(item) {
        if (!item) return
        const needle = ((item.title || item.id || "")).toLowerCase()

        if (needle.length >= 2) {
            Hyprland.refreshToplevels()
            const wins = Hyprland.toplevels.values

            for (let i = 0; i < wins.length; i++) {
                const w = wins[i]
                const rawCls = (w.wmClass || w.class || "")
                const cls = rawCls.toLowerCase()
                const title = (w.title || "").toLowerCase()

                const clsMatch = cls.length > 0 && (cls.includes(needle) || needle.includes(cls))
                const titleMatch = title.length > 0 && title.includes(needle)

                if (clsMatch || titleMatch) {
                    if (rawCls) {
                        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ window = 'class:^(" + escapeRegex(rawCls) + ")$' })"])
                    } else if (w.address) {
                        const addr = w.address.startsWith("0x") ? w.address : "0x" + w.address
                        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ window = 'address:" + addr + "' })"])
                    }
                    return
                }
            }
        }

        item.activate()
    }

    width: parent ? parent.width : 220
    height: parent ? parent.height : 250
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.85
    y: active ? 0 : 4
    visible: opacity > 0

    SequentialAnimation {
        id: flashAnim

        NumberAnimation {
            target: root
            property: "scale"
            to: 1.06
            duration: 80
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 130
            easing.type: Easing.OutBack
            easing.overshoot: 1.3
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.count === 0
        text: "No tray apps running"
        color: Colors.muted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        renderType: Text.NativeRendering
    }

    ListView {
        id: trayList
        anchors.fill: parent
        anchors.margins: 6
        clip: true
        visible: root.count > 0
        model: SystemTray.items ? SystemTray.items.values : []
        spacing: 3

        delegate: Rectangle {
            id: trayRow
            required property var modelData

            width: ListView.view ? ListView.view.width : 208
            height: 36
            radius: Radius.small
            color: rowHover.containsMouse ? Colors.hover : Colors.transparent

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 10

                Image {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source: trayRow.modelData.icon || ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }

                Text {
                    text: trayRow.modelData.title || trayRow.modelData.id || "Unknown"
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: parent.width - 30
                    renderType: Text.NativeRendering
                }
            }

            MouseArea {
                id: rowHover
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (trayRow.modelData.menu) {
                            root.menuRequested(trayRow.modelData.menu)
                        }
                    } else {
                        root.focusOrOpen(trayRow.modelData)
                    }
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
