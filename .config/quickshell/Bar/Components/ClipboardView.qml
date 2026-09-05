import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    property var historyItems: []
    property var filteredItems: []
    property int selectedIndex: 0
    property var previewPaths: ({})

    signal closeRequested()

    function stepUp() {
        if (selectedIndex > 0) {
            selectedIndex--
            listView.positionViewAtIndex(selectedIndex, ListView.Beginning)
        }
    }

    function stepDown() {
        if (selectedIndex < filteredItems.length - 1) {
            selectedIndex++
            listView.positionViewAtIndex(selectedIndex, ListView.End)
        }
    }

    function copyCurrent() {
        if (filteredItems.length > 0 && selectedIndex >= 0 && selectedIndex < filteredItems.length) {
            copySelected(filteredItems[selectedIndex])
        }
    }

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(function(l) { return l.trim().length > 0 })
                root.historyItems = lines
                root.filterItems()
            }
        }
    }

    Process { id: actionProcess }

    Process {
        id: previewProcess
        property string targetId: ""
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path.length > 0 && previewProcess.targetId !== "") {
                    let updated = Object.assign({}, root.previewPaths)
                    updated[previewProcess.targetId] = "file://" + path
                    root.previewPaths = updated
                }
            }
        }
    }

    function reloadHistory() {
        listProcess.running = true
    }

    onActiveChanged: {
        if (active) {
            reloadHistory()
            searchInput.text = ""
            searchInput.forceActiveFocus()
        }
    }

    function filterItems() {
        const query = searchInput.text.toLowerCase().trim()
        if (query === "") {
            filteredItems = historyItems
        } else {
            filteredItems = historyItems.filter(function(item) {
                return item.toLowerCase().includes(query)
            })
        }
        selectedIndex = 0
        fetchPreviewsForSelected()
    }

    onSelectedIndexChanged: {
        fetchPreviewsForSelected()
    }

    function getItemId(rawText) {
        if (!rawText) return ""
        const tabIdx = rawText.indexOf('\t')
        if (tabIdx !== -1) return rawText.substring(0, tabIdx).trim()
        const match = rawText.match(/^(\d+)/)
        return match ? match[1] : ""
    }

    function cleanContent(rawText) {
        if (!rawText) return ""
        const tabIdx = rawText.indexOf('\t')
        if (tabIdx !== -1) return rawText.substring(tabIdx + 1).trim()
        return rawText.replace(/^\d+\s+/, '').trim()
    }

    function isImageItem(rawText) {
        if (!rawText) return false
        const clean = cleanContent(rawText).toLowerCase()
        return clean.includes("binary data") || clean.includes("image/") || clean.includes("[[ binary")
    }

    function getItemIcon(rawText) {
        if (isImageItem(rawText)) return "\uf03e"
        const clean = cleanContent(rawText)
        if (clean.startsWith("http://") || clean.startsWith("https://") || clean.startsWith("www.")) return "\uf0c1"
        if (clean.startsWith("{") || clean.startsWith("[") || clean.includes("function") || clean.includes("const ")) return "\uf121"
        if (clean.includes("\n")) return "\uf02d"
        return "\uf0ea"
    }

    function fetchPreviewsForSelected() {
        if (filteredItems.length === 0 || selectedIndex < 0 || selectedIndex >= filteredItems.length) return
        const currentItem = filteredItems[selectedIndex]
        if (!isImageItem(currentItem)) return

        const id = getItemId(currentItem)
        if (root.previewPaths[id] || id === "") return

        previewProcess.targetId = id
        previewProcess.running = false
        previewProcess.command = ["bash", "-c", "$HOME/.local/bin/clipboard.sh preview '" + id + "'"]
        previewProcess.running = true
    }

    function copySelected(item) {
        if (!item) return
        const id = getItemId(item)
        if (id === "") return
        actionProcess.command = ["bash", "-c", "$HOME/.local/bin/clipboard.sh copy '" + id + "'"]
        actionProcess.running = true
        root.closeRequested()
    }

    function deleteSelected(item) {
        if (!item) return
        const id = getItemId(item)
        if (id === "") return
        actionProcess.command = ["bash", "-c", "$HOME/.local/bin/clipboard.sh delete '" + id + "'"]
        actionProcess.running = true
        reloadHistory()
    }

    function clearAllHistory() {
        actionProcess.command = ["bash", "-c", "$HOME/.local/bin/clipboard.sh clear"]
        actionProcess.running = true
        reloadHistory()
    }

    Keys.onUpPressed: stepUp()
    Keys.onDownPressed: stepDown()
    Keys.onReturnPressed: copyCurrent()
    Keys.onEscapePressed: closeRequested()

    anchors.fill: parent
    anchors.margins: 12
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.97
    visible: opacity > 0

    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    Column {
        anchors.fill: parent
        spacing: 10

        
        Rectangle {
            width: parent.width
            height: 38
            radius: Radius.button
            color: Colors.islandBg
            border.color: searchInput.activeFocus 
                ? Colors.blue 
                : Colors.transparent
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 10

                Text {
                    text: "\uf002"
                    color: searchInput.activeFocus ? Colors.blue : Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }

                TextInput {
                    id: searchInput
                    width: parent.width - 100
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    clip: true

                    onTextChanged: root.filterItems()

                    Keys.onUpPressed: function(event) { root.stepUp(); event.accepted = true }
                    Keys.onDownPressed: function(event) { root.stepDown(); event.accepted = true }
                    Keys.onReturnPressed: function(event) { root.copyCurrent(); event.accepted = true }
                    Keys.onEscapePressed: function(event) { root.closeRequested(); event.accepted = true }

                    Text {
                        text: "Type to filter history..."
                        color: Colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        visible: !searchInput.text && !searchInput.inputMethodComposing
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20
                    width: countText.implicitWidth + 12
                    radius: Radius.badge
                    color: Colors.surface

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: root.filteredItems.length + " items"
                        color: Colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }
                }
            }
        }

        
        Item {
            width: parent.width
            height: parent.height - 70

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                model: root.filteredItems
                currentIndex: root.selectedIndex
                spacing: 6
                visible: root.filteredItems.length > 0

                delegate: Rectangle {
                    id: itemDelegate
                    required property string modelData
                    required property int index

                    readonly property bool isSelected: index === root.selectedIndex
                    readonly property bool isImage: root.isImageItem(modelData)
                    readonly property string itemId: root.getItemId(modelData)
                    readonly property string imagePath: isImage ? (root.previewPaths[itemId] || "") : ""
                    width: listView.width
                    height: isImage ? (isSelected ? 220 : 42) : 42
                    radius: Radius.button
                    color: isSelected 
                        ? Colors.surface 
                        : (rowHover.containsMouse ? Colors.hover : Colors.transparent)
                    border.color: isSelected 
                        ? Colors.blue 
                        : Colors.transparent
                    border.width: 1
                    clip: true

                    Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    
                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.selectedIndex === index) {
                                root.copySelected(modelData)
                            } else {
                                root.selectedIndex = index
                            }
                        }
                    }

                    Column {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            width: parent.width
                            height: 42

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 8
                                spacing: 12

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.getItemIcon(modelData)
                                    color: isSelected ? Colors.blue : Colors.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 68
                                    text: isImage ? "Image capture (" + itemId + ")" : root.cleanContent(modelData)
                                    elide: Text.ElideRight
                                    color: Colors.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    renderType: Text.NativeRendering
                                }

                                
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 26
                                    height: 26
                                    radius: Radius.small
                                    color: delMouse.containsMouse ? Colors.red : Colors.transparent
                                    
                                    opacity: rowHover.containsMouse || isSelected ? 1 : 0

                                    Behavior on opacity { NumberAnimation { duration: 120 } }
                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\uf2ed"
                                        color: delMouse.containsMouse ? Colors.text : Colors.red
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        renderType: Text.NativeRendering
                                    }

                                    MouseArea {
                                        id: delMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: function(mouse) {
                                            mouse.accepted = true
                                            root.deleteSelected(modelData)
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: 178
                            visible: isImage && isSelected

                            Rectangle {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 10
                                radius: Radius.button
                                color: Colors.bg
                                border.color: Colors.border
                                border.width: 1
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    source: imagePath
                                    visible: imagePath !== ""
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: imagePath === ""
                                    text: "Decoding preview..."
                                    color: Colors.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: root.filteredItems.length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uf072"
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 24
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: searchInput.text.length > 0 ? "No matching records" : "Clipboard is empty"
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    renderType: Text.NativeRendering
                }
            }
        }

        
        Row {
            width: parent.width
            height: 18

            Rectangle {
                height: 18
                width: clearAllText.implicitWidth + 12
                radius: Radius.small
                color: clearAllHover.containsMouse ? Colors.red : Colors.transparent

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: clearAllText
                    anchors.centerIn: parent
                    text: "Clear History"
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
                    onClicked: root.clearAllHistory()
                }
            }

            Item { width: parent.width - clearAllText.implicitWidth - hintText.implicitWidth - 12; height: 1 }

            Text {
                id: hintText
                anchors.verticalCenter: parent.verticalCenter
                text: "↑ ↓ Navigate  |  ↵ Copy  |  Esc Close"
                color: Colors.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
                renderType: Text.NativeRendering
            }
        }
    }
}