import QtQuick
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false

    property var wifiSystem
    property var btSystem
    property var micSystem
    property var camSystem
    property var caffeineSystem
    property var volSystem
    property var brightSystem

    signal closeRequested()

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    anchors.fill: parent
    anchors.margins: 10
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.92
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 240; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }

    component ToggleTile: Rectangle {
        id: tile
        property string glyph: ""
        property string label: ""
        property string statusText: ""
        property bool active: false
        signal clicked()

        width: 130
        height: 52
        radius: 0
        color: active ? Colors.hover : Colors.elevated
        border.color: active ? Colors.blue : Colors.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Text {
                text: tile.glyph
                color: tile.active ? Colors.blue : Colors.textSecondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering

                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                width: parent.width - 26

                Text {
                    text: tile.label
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                    renderType: Text.NativeRendering
                }

                Text {
                    text: tile.statusText
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
            onClicked: tile.clicked()
        }
    }

    Column {
        anchors.fill: parent
        spacing: 8

        Row {
            spacing: 8
            ToggleTile {
                glyph: "\uf1eb"
                label: "Wifi"
                statusText: root.wifiSystem.wifiEnabled
                    ? (root.wifiSystem.connectedSsid || "On")
                    : "Off"
                active: root.wifiSystem.wifiEnabled
                onClicked: root.wifiSystem.toggle()
            }
            ToggleTile {
                glyph: "\uf294"
                label: "Bluetooth"
                statusText: root.btSystem.isPowered
                    ? (root.btSystem.connectedDevice || "On")
                    : "Off"
                active: root.btSystem.isPowered
                onClicked: root.btSystem.toggle()
            }
        }

        Row {
            spacing: 8
            ToggleTile {
                glyph: "\uf1f2"
                label: "Peace"
                statusText: DndState.enabled ? "On" : "Off"
                active: DndState.enabled
                onClicked: DndState.enabled = !DndState.enabled
            }
            ToggleTile {
                glyph: "\uf0f4"
                label: "Caffeine"
                statusText: root.caffeineSystem.isActive ? "On" : "Off"
                active: root.caffeineSystem.isActive
                onClicked: root.caffeineSystem.toggle()
            }
        }

        Row {
            spacing: 8
            ToggleTile {
                glyph: "\uf030"
                label: "Camera"
                statusText: root.camSystem.isOn ? "On" : "Off"
                active: root.camSystem.isOn
                onClicked: root.camSystem.toggle()
            }
            ToggleTile {
                glyph: "\uf130"
                label: "Microphone"
                statusText: root.micSystem.isMuted ? "Off" : "On"
                active: !root.micSystem.isMuted
                onClicked: root.micSystem.toggle()
            }
        }

        Column {
            width: parent.width
            spacing: 4
            topPadding: 4

            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: "\uf028"
                    color: Colors.textSecondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    width: parent.width - 22
                    height: 6
                    radius: 0
                    color: Colors.osdTrackBg
                    anchors.verticalCenter: parent.verticalCenter
                    clip: true

                    Rectangle {
                        width: Math.min(parent.width, Math.max(0, (parent.width * root.volSystem.volumeLevel) / 100))
                        height: parent.height
                        color: root.volSystem.isMuted ? Colors.muteAccent : Colors.volumeAccent
                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            const fraction = mouse.x / width
                            const pct = Math.round(fraction * 100)
                            volSetProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct / 100]
                            volSetProcess.running = true
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: "\uf042"
                    color: Colors.textSecondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    width: parent.width - 22
                    height: 6
                    radius: 0
                    color: Colors.osdTrackBg
                    anchors.verticalCenter: parent.verticalCenter
                    clip: true

                    Rectangle {
                        width: Math.min(parent.width, Math.max(0, (parent.width * root.brightSystem.brightnessLevel) / 100))
                        height: parent.height
                        color: Colors.brightnessAccent
                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            const fraction = mouse.x / width
                            const pct = Math.max(1, Math.round(fraction * 100))
                            brightSetProcess.command = ["brightnessctl", "set", pct + "%"]
                            brightSetProcess.running = true
                        }
                    }
                }
            }
        }
    }

    Process {
        id: volSetProcess
    }
    Process {
        id: brightSetProcess
    }
}
