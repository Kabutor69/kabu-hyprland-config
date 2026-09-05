import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    property var wallpapers: []
    property var filteredWallpapers: []
    property string appliedPath: ""
    property int currentIndex: 0

    signal closeRequested()

    function pulse() { flashAnim.restart() }

    function stepLeft() {
        if (filteredWallpapers.length > 0) {
            currentIndex = (currentIndex - 1 + filteredWallpapers.length) % filteredWallpapers.length
        }
    }

    function stepRight() {
        if (filteredWallpapers.length > 0) {
            currentIndex = (currentIndex + 1) % filteredWallpapers.length
        }
    }

    onActiveChanged: {
        if (active) {
            listProcess.running = true
            searchInput.text = ""
            searchInput.forceActiveFocus()
        }
    }

    function filterWallpapers() {
        const query = searchInput.text.toLowerCase().trim()
        if (query === "") {
            filteredWallpapers = wallpapers
        } else {
            filteredWallpapers = wallpapers.filter(path => {
                const name = path.substring(path.lastIndexOf("/") + 1).toLowerCase()
                return name.includes(query)
            })
        }
        if (currentIndex >= filteredWallpapers.length) {
            currentIndex = Math.max(0, filteredWallpapers.length - 1)
        }
    }

    function applyCurrent() {
        if (filteredWallpapers.length > 0 && currentIndex >= 0 && currentIndex < filteredWallpapers.length) {
            applyWallpaper(filteredWallpapers[currentIndex])
            root.closeRequested()
        }
    }

    function applyWallpaper(path) {
        root.appliedPath = path
        applyProcess.targetPath = path
        applyProcess.running = true
    }

    Keys.onLeftPressed: stepLeft()
    Keys.onRightPressed: stepRight()
    Keys.onReturnPressed: applyCurrent()
    Keys.onEscapePressed: closeRequested()

    anchors.fill: parent
    anchors.margins: 14
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.98
    visible: opacity > 0

    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: root; property: "scale"; to: 1.01; duration: 60 }
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 100 }
    }

    Process {
        id: listProcess
        command: ["sh", "-c",
            "find \"$HOME/Pictures/wallpapers\" -maxdepth 1 -type f " +
            "\\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \\) " +
            "2>/dev/null | sort"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
                root.wallpapers = lines
                root.filterWallpapers()
            }
        }
    }

    Process {
        id: applyProcess
        property string targetPath: ""
        command: ["sh", "-c", "$HOME/.local/bin/select-wallpaper.sh \"" + targetPath + "\""]
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            width: parent.width
            height: 36
            radius: Radius.button
            color: Colors.elevated
            border.color: searchInput.activeFocus 
                ? Colors.blue 
                : Colors.border
            border.width: searchInput.activeFocus ? 2 : 1

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
                    width: parent.width - 80
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    clip: true

                    onTextChanged: root.filterWallpapers()

                    Keys.onLeftPressed: event => { root.stepLeft(); event.accepted = true }
                    Keys.onRightPressed: event => { root.stepRight(); event.accepted = true }
                    Keys.onReturnPressed: event => { root.applyCurrent(); event.accepted = true }
                    Keys.onEscapePressed: event => { root.closeRequested(); event.accepted = true }

                    Text {
                        text: "Search wallpapers..."
                        color: Colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        visible: !searchInput.text && !searchInput.inputMethodComposing
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    text: searchInput.text.length > 0 ? "\uf00d" : (root.filteredWallpapers.length + " items")
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        enabled: searchInput.text.length > 0
                        cursorShape: Qt.PointingHandCursor
                        onClicked: searchInput.text = ""
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: parent.height - 70
            visible: root.filteredWallpapers.length > 0
            clip: true

            PathView {
                id: pathView
                anchors.fill: parent
                model: root.filteredWallpapers
                currentIndex: root.currentIndex
                onCurrentIndexChanged: root.currentIndex = currentIndex
                pathItemCount: 3
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5

                path: Path {
                    startX: pathView.width * 0.1
                    startY: pathView.height / 2

                    PathAttribute { name: "itemScale"; value: 0.76 }
                    PathAttribute { name: "itemOpacity"; value: 0.45 }
                    PathAttribute { name: "itemZ"; value: 1 }

                    PathLine {
                        x: pathView.width * 0.5
                        y: pathView.height / 2
                    }

                    PathAttribute { name: "itemScale"; value: 1.0 }
                    PathAttribute { name: "itemOpacity"; value: 1.0 }
                    PathAttribute { name: "itemZ"; value: 10 }

                    PathLine {
                        x: pathView.width * 0.9
                        y: pathView.height / 2
                    }

                    PathAttribute { name: "itemScale"; value: 0.76 }
                    PathAttribute { name: "itemOpacity"; value: 0.45 }
                    PathAttribute { name: "itemZ"; value: 1 }
                }

                delegate: Item {
                    id: delegateItem
                    required property var modelData
                    required property int index

                    width: pathView.width * 0.58
                    height: width * 0.58

                    scale: PathView.itemScale
                    opacity: PathView.itemOpacity
                    z: PathView.itemZ

                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    readonly property bool isSelected: index === pathView.currentIndex
                    readonly property bool isApplied: modelData === root.appliedPath

                    Item {
                        anchors.fill: parent

                        Item {
                            id: imageMaskContainer
                            anchors.fill: parent
                            layer.enabled: true
                            layer.smooth: true

                            layer.effect: ShaderEffect {
                                property var source: imageMaskContainer
                                property var maskSource: ShaderEffectSource {
                                    sourceItem: Rectangle {
                                        width: imageMaskContainer.width
                                        height: imageMaskContainer.height
                                        radius: 14
                                        color: "black"
                                    }
                                }
                            }

                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                sourceSize.width: 500
                                sourceSize.height: 300
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: Radius.card
                            color: "transparent"
                            border.color: isSelected 
                                ? Colors.blue 
                                : Colors.border
                            border.width: isSelected ? 2 : 1
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            width: 24; height: 24; radius: Radius.badge
                            color: Colors.blue
                            visible: isApplied
                            z: 10

                            Text {
                                anchors.centerIn: parent
                                text: "\uf00c"
                                color: Colors.bg
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                                renderType: Text.NativeRendering
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentIndex === index) {
                                root.applyCurrent()
                            } else {
                                root.currentIndex = index
                            }
                        }
                    }
                }
            }

            Rectangle {
                z: 100
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 4
                width: 32; height: 32; radius: 16
                color: leftNavHover.containsMouse ? Colors.elevated : Colors.overlay

                Text {
                    anchors.centerIn: parent
                    text: "\uf053"
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: leftNavHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.stepLeft()
                }
            }

            Rectangle {
                z: 100
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 4
                width: 32; height: 32; radius: 16
                color: rightNavHover.containsMouse ? Colors.elevated : Colors.overlay

                Text {
                    anchors.centerIn: parent
                    text: "\uf054"
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: rightNavHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.stepRight()
                }
            }
        }

        Row {
            width: parent.width
            height: 20
            visible: root.filteredWallpapers.length > 0

            Text {
                width: parent.width - 130
                elide: Text.ElideRight
                text: {
                    if (root.filteredWallpapers.length > 0 && root.currentIndex < root.filteredWallpapers.length) {
                        const path = root.filteredWallpapers[root.currentIndex]
                        return path.substring(path.lastIndexOf("/") + 1)
                    }
                    return ""
                }
                color: Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
                renderType: Text.NativeRendering
            }

            Text {
                width: 130
                horizontalAlignment: Text.AlignRight
                text: "← → Navigate  |  ↵ Apply | Esc Close"
                color: Colors.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
                renderType: Text.NativeRendering
            }
        }
    }
}
