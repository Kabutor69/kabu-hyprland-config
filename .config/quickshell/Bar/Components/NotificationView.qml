import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import "../../"

Item {
    id: root

    property var system
    property bool active: false

    function pulse() {
        notifIconPulse.restart()
    }

    readonly property string cleanBody:
        (system && system.notifBody ? system.notifBody : "").replace(/\s+/g, " ").trim()

    readonly property bool hasBody: cleanBody !== ""
    readonly property bool isCritical: system ? system.notifUrgency === 2 : false

    function imageSource(raw) {
        if (!raw)
            return ""

        if (raw.startsWith("/"))
            return "file://" + raw

        if (
            raw.startsWith("http://") ||
            raw.startsWith("https://") ||
            raw.startsWith("file://") ||
            raw.startsWith("image://")
        )
            return raw

        return Quickshell.iconPath(raw)
    }

    function escapeRegex(s) {
        return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    }

    function focusOrLaunch() {
        if (!root.system)
            return

        const needle = ((root.system.notifAppName || root.system.notifTitle || "")).toLowerCase()
        if (needle.length < 2)
            return

        Hyprland.refreshToplevels()
        const wins = Hyprland.toplevels.values

        for (let i = 0; i < wins.length; i++) {
            const w = wins[i]
            const rawCls = (w.wmClass || w.class || "")
            const cls = rawCls.toLowerCase()
            const title = (w.title || "").toLowerCase()

            const clsMatch =
                cls.length > 0 &&
                (cls.includes(needle) || needle.includes(cls))

            const titleMatch =
                title.length > 0 &&
                title.includes(needle)

            if (clsMatch || titleMatch) {
                if (rawCls) {
                    Quickshell.execDetached([
                        "hyprctl",
                        "dispatch",
                        "hl.dsp.focus({ window = 'class:^(" +
                        escapeRegex(rawCls) +
                        ")$' })"
                    ])
                } else if (w.address) {
                    const addr =
                        w.address.startsWith("0x")
                        ? w.address
                        : "0x" + w.address

                    Quickshell.execDetached([
                        "hyprctl",
                        "dispatch",
                        "hl.dsp.focus({ window = 'address:" + addr + "' })"
                    ])
                }

                return
            }
        }

        const apps = [...DesktopEntries.applications.values]

        for (let i = 0; i < apps.length; i++) {
            const name = (apps[i].name || "").toLowerCase()

            if (name.includes(needle) || needle.includes(name)) {
                apps[i].execute()
                return
            }
        }
    }

    width: 250
    height: parent ? parent.height : 32
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.85
    y: active ? 0 : 4
    visible: opacity > 0

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Item {
            id: notifIconBadge

            width: 22
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            scale: 1

            SequentialAnimation {
                id: notifIconPulse

                NumberAnimation {
                    target: notifIconBadge
                    property: "scale"
                    to: 1.3
                    duration: 90
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: notifIconBadge
                    property: "scale"
                    to: 1
                    duration: 140
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            readonly property bool hasDistinctImage:
                root.system &&
                root.system.notifImage !== "" &&
                root.system.notifAppIcon !== "" &&
                root.system.notifImage !== root.system.notifAppIcon

            
            Item {
                id: notifImageWrapper
                anchors.fill: parent
                visible: notifIconImg.visible

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: notifImageWrapper.width
                        height: notifImageWrapper.height
                        radius: Radius.small
                    }
                }

                Image {
                    id: notifIconImg

                    anchors.fill: parent

                    source: root.imageSource(
                        root.system
                        ? (root.system.notifAppIcon || root.system.notifImage || "")
                        : ""
                    )

                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }
            }

            
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: Colors.islandBg
                visible: notifIconBadge.hasDistinctImage
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -2
                anchors.bottomMargin: -2

                Image {
                    id: appBadgeImg

                    anchors.fill: parent
                    anchors.margins: 1

                    source: notifIconBadge.hasDistinctImage && root.system
                        ? root.imageSource(root.system.notifAppIcon || "")
                        : ""

                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: status === Image.Ready
                }
            }

            
            Text {
                id: notifIcon

                anchors.centerIn: parent
                visible: !notifIconImg.visible
                text: "\uf0f3"
                color: root.isCritical
                    ? Colors.red
                    : Colors.textSecondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            
            Rectangle {
                width: 7
                height: 7
                radius: 3.5
                color: Colors.red
                visible: root.isCritical
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -2
                anchors.topMargin: -2
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.hasBody ? 1 : 0
            width: parent.width - notifIconBadge.width - parent.spacing

            Text {
                text: root.system && root.system.notifTitle ? root.system.notifTitle : ""
                color: Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 0.2
                elide: Text.ElideRight
                width: parent.width
                renderType: Text.NativeRendering
            }

            Text {
                text: root.cleanBody
                color: Colors.textSecondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                elide: Text.ElideRight
                width: parent.width
                renderType: Text.NativeRendering
                visible: root.hasBody
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.focusOrLaunch()
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
