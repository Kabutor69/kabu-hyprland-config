import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    property int appRefresh: 0

    signal closeRequested()

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.appRefresh++
    }

    function focusSearch() {
        searchInput.forceActiveFocus()
    }

    function reset() {
        searchInput.text = ""
        resultList.currentIndex = 0
    }

    anchors.fill: parent
    anchors.margins: 12
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.92
    visible: opacity > 0

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

    ScriptModel {
        id: filteredApps

        values: {
            root.appRefresh

            const q = searchInput.text.trim().toLowerCase()

            const all = [...DesktopEntries.applications.values]
                .filter(d => d.name)
                .sort((a, b) => a.name.localeCompare(b.name))

            if (q === "")
                return all

            return all.filter(d => {
                const name = (d.name || "").toLowerCase()
                const comment = (d.comment || "").toLowerCase()

                return name.includes(q) || comment.includes(q)
            })
        }
    }

    function shQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function findExistingWindow(entry) {
        const needle = ((entry.icon || entry.name || "")).toLowerCase()

        if (!needle || needle.length < 2)
            return null

        Hyprland.refreshToplevels()

        const wins = Hyprland.toplevels.values

        for (let i = 0; i < wins.length; i++) {
            const w = wins[i]
            const cls = (w.wmClass || w.class || "").toLowerCase()
            const title = (w.title || "").toLowerCase()

            const clsMatch =
                cls.length > 0 &&
                (cls.includes(needle) || needle.includes(cls))

            const titleMatch =
                title.length > 0 &&
                title.includes(needle)

            if (clsMatch || titleMatch)
                return w
        }

        return null
    }

    function escapeRegex(s) {
        return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    }

    function launch(entry) {
        if (!entry)
            return

        const existing = findExistingWindow(entry)

        if (existing) {
            const existingCls = existing.wmClass || existing.class || ""

            if (existingCls) {
                Quickshell.execDetached([
                    "hyprctl",
                    "dispatch",
                    "hl.dsp.focus({ window = 'class:^(" +
                    escapeRegex(existingCls) +
                    ")$' })"
                ])
            } else if (existing.address) {
                const addr =
                    existing.address.startsWith("0x")
                    ? existing.address
                    : "0x" + existing.address

                Quickshell.execDetached([
                    "hyprctl",
                    "dispatch",
                    "hl.dsp.focus({ window = 'address:" + addr + "' })"
                ])
            } else if (typeof existing.activate === "function") {
                existing.activate()
            }

            root.closeRequested()
            return
        }

        const home = Quickshell.env("HOME") || "/"
        const workDir = entry.workingDirectory || home

        if (entry.runInTerminal) {
            Quickshell.execDetached(
                ["kitty", "--directory", workDir, "-e"].concat(entry.command)
            )
        } else {
            const cmdStr = entry.command.map(shQuote).join(" ")

            Quickshell.execDetached([
                "sh",
                "-c",
                "cd " + shQuote(workDir) + " && exec " + cmdStr
            ])
        }

        root.closeRequested()
    }

    Column {
        anchors.fill: parent
        spacing: 10

        
        Rectangle {
            width: parent.width
            height: 38
            radius: Radius.tile
            color: Colors.tileBg
            border.color: searchInput.activeFocus ? Colors.blue : Colors.tileBorder
            border.width: 1

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "\uf002"
                    color: searchInput.activeFocus ? Colors.blue : Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }

                TextInput {
                    id: searchInput

                    width: parent.width - 28
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    clip: true

                    Text {
                        text: "Search software..."
                        color: Colors.muted
                        font: parent.font
                        visible: searchInput.text.length === 0
                        renderType: Text.NativeRendering
                    }

                    Keys.onEscapePressed: root.closeRequested()

                    Keys.onReturnPressed:
                        root.launch(
                            filteredApps.values[resultList.currentIndex]
                        )

                    Keys.onDownPressed:
                        resultList.incrementCurrentIndex()

                    Keys.onUpPressed:
                        resultList.decrementCurrentIndex()

                    onTextChanged:
                        resultList.currentIndex = 0
                }
            }
        }

        
        ListView {
            id: resultList

            width: parent.width
            height: parent.height - 48
            clip: true
            model: filteredApps
            currentIndex: 0
            spacing: 2
            highlightMoveDuration: 120
            keyNavigationWraps: false

            onCountChanged: currentIndex = 0

            delegate: Rectangle {
                id: itemTile
                width: resultList.width
                height: 44
                radius: Radius.button

                required property var modelData
                required property int index

                color: ListView.isCurrentItem
                    ? Colors.tileActiveBg
                    : Colors.transparent
                border.color: ListView.isCurrentItem
                    ? Colors.tileActiveBorder
                    : Colors.transparent
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 12

                    Item {
                        id: iconContainer

                        width: 26
                        height: 26
                        anchors.verticalCenter: parent.verticalCenter

                        property string liveFoundIcon: ""

                        Process {
                            id: iconProbe

                            running: false

                            command: [
                                "sh",
                                "-c",
                                "find /usr/share/icons /usr/share/pixmaps ~/.local/share/icons ~/.icons " +
                                "-type f \\( -iname '" +
                                (modelData.icon || "").replace(/'/g, "") +
                                ".png' -o -iname '" +
                                (modelData.icon || "").replace(/'/g, "") +
                                ".svg' -o -iname '" +
                                (modelData.icon || "").replace(/'/g, "") +
                                ".xpm' \\) 2>/dev/null | head -n1"
                            ]

                            stdout: StdioCollector {
                                onStreamFinished: {
                                    const path = text.trim()

                                    if (path.length > 0)
                                        iconContainer.liveFoundIcon =
                                            "file://" + path
                                }
                            }
                        }

                        Component.onCompleted: {
                            if (
                                modelData.icon &&
                                !modelData.icon.startsWith("/")
                            ) {
                                iconProbe.running = true
                            }
                        }

                        Image {
                            id: appIcon

                            anchors.fill: parent

                            source: {
                                if (!modelData.icon)
                                    return ""

                                if (modelData.icon === "hwloc")
                                    return ""

                                if (iconContainer.liveFoundIcon !== "")
                                    return iconContainer.liveFoundIcon

                                if (modelData.icon.startsWith("/"))
                                    return "file://" + modelData.icon

                                return Quickshell.iconPath(
                                    modelData.icon,
                                    false
                                )
                            }

                            fillMode: Image.PreserveAspectFit
                            asynchronous: true

                            visible:
                                status === Image.Ready &&
                                paintedWidth > 0
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !appIcon.visible
                            text: "\uf1b2"
                            color: Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            renderType: Text.NativeRendering
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 38
                        spacing: 2

                        Text {
                            text: modelData.name || ""
                            color: Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: modelData.comment || ""
                            visible: text !== ""
                            color: Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            elide: Text.ElideRight
                            width: parent.width
                            renderType: Text.NativeRendering
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onEntered:
                        resultList.currentIndex = index

                    onClicked:
                        root.launch(modelData)
                }
            }
        }
    }
}
