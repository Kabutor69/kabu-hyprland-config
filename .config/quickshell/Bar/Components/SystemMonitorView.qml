import QtQuick
import QtQuick.Layouts
import "../../"

Item {
    id: root

    property bool active: false
    property var system

    signal closeRequested()

    function pulse() { flashAnim.restart() }
    
    function formatSize(value) {
        if (!value || value === 0) return "0M"
        if (value >= 1) return value.toFixed(1) + "G"
        return (value * 1024).toFixed(0) + "M"
    }

    function formatUsageText(used, total) {
        return formatSize(used) + " / " + formatSize(total)
    }

    width: parent ? parent.width : 540
    height: parent ? parent.height : 290
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.94
    visible: opacity > 0

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 1.08 }
    }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: root; property: "scale"; to: 1.02; duration: 90; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Radius.card || 24
        color: Colors.islandBg
        border.color: Colors.border
        border.width: 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "SYSTEM MONITOR"
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.5
                    renderType: Text.NativeRendering
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: uptimeRow.implicitWidth + 16
                    implicitHeight: 22
                    radius: Radius.capsule || 11
                    color: Colors.elevated

                    RowLayout {
                        id: uptimeRow
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "\uf017"
                            color: Colors.cyan
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: (root.system && root.system.uptime) ? ("UP " + root.system.uptime) : "UP 0m"
                            color: Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }

            Repeater {
                model: [
                    { type: "cpu", icon: "\uf2db", label: "CPU" },
                    { type: "mem", icon: "\uf080", label: "MEMORY" },
                    { type: "swap", icon: "\uf0c7", label: "SWAP" },
                    { type: "disk", icon: "\uf0a0", label: "STORAGE" }
                ]

                delegate: Rectangle {
                    id: rowTile
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Radius.tile || 14
                    color: Colors.tileBg
                    border.color: animatedPct > 85 ? accentColor : Colors.tileBorder
                    border.width: 1

                    property real targetPct: {
                        if (!root.system) return 0
                        switch (modelData.type) {
                            case "cpu": return root.system.cpuPercent || 0
                            case "mem": return root.system.memPercent || 0
                            case "swap": return root.system.swapPercent || 0
                            case "disk": return root.system.diskPercent || 0
                            default: return 0
                        }
                    }

                    property string exactText: {
                        if (!root.system) return "0 / 0"
                        switch (modelData.type) {
                            case "cpu": return root.system.cpuTemp > 0 ? (Math.round(targetPct) + "% • " + root.system.cpuTemp + "°C") : (Math.round(targetPct) + "%")
                            case "mem": return root.formatUsageText(root.system.memUsed, root.system.memTotal)
                            case "swap": return root.formatUsageText(root.system.swapUsed, root.system.swapTotal)
                            case "disk": return root.formatUsageText(root.system.diskUsed, root.system.diskTotal)
                            default: return ""
                        }
                    }

                    property color accentColor: {
                        if (targetPct > 85) return Colors.red
                        if (targetPct > 60) return Colors.purple
                        return modelData.type === "mem" ? Colors.cyan : (modelData.type === "swap" ? Colors.green : Colors.blue)
                    }

                    property real animatedPct: targetPct
                    Behavior on animatedPct {
                        NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Rectangle {
                            width: 32
                            height: 32
                            radius: Radius.capsule || 10
                            color: Colors.elevated

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: rowTile.accentColor
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                renderType: Text.NativeRendering
                            }
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.preferredWidth: 90

                            Text {
                                text: modelData.label
                                color: Colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: rowTile.exactText
                                color: Colors.textSecondary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                renderType: Text.NativeRendering
                            }
                        }

                        Item {
                            id: barContainer
                            Layout.fillWidth: true
                            height: 8

                            Rectangle {
                                anchors.fill: parent
                                radius: Radius.slider || 4
                                color: Colors.osdTrackBg
                                antialiasing: true
                            }

                            Rectangle {
                                height: parent.height
                                width: Math.max(8, parent.width * (Math.min(100, rowTile.animatedPct) / 100))
                                radius: Radius.slider || 4
                                color: rowTile.accentColor
                                antialiasing: true

                                Behavior on width {
                                    NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 250 }
                                }
                            }
                        }

                        Text {
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(rowTile.animatedPct) + "%"
                            color: Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
        }
    }
}