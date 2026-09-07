import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    property int selectedIndex: 0
    signal closeRequested()

    readonly property var actions: [
        {
            icon: "\uf023",
            label: "Lock",
            accentColor: Colors.blue,
            cmd: ["loginctl", "lock-session"]
        },
        {
            icon: "\uf236",
            label: "Sleep",
            accentColor: Colors.blue,
            cmd: ["systemctl", "suspend"]
        },
        {
            icon: "\uf2f5",
            label: "Logout",
            accentColor: Colors.blue,
            cmd: ["hyprctl", "dispatch", "exit"]
        },
        {
            icon: "\uf011",
            label: "Shutdown",
            accentColor: Colors.blue,
            cmd: ["systemctl", "poweroff"]
        },
        {
            icon: "\uf01e",
            label: "Reboot",
            accentColor: Colors.blue,
            cmd: ["systemctl", "reboot"]
        }
    ]

    function runAction(index) {
        if (index < 0 || index >= root.actions.length) return
        actionProc.command = root.actions[index].cmd
        actionProc.running = true
        root.closeRequested()
    }

    anchors.fill: parent

    opacity: active ? 1 : 0
    scale: active ? 1 : 0.88
    visible: opacity > 0
    focus: active

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }

    onActiveChanged: {
        if (active) {
            root.selectedIndex = 0
            root.forceActiveFocus()
        }
    }

    Process {
        id: actionProc
        running: false
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    Keys.onLeftPressed: {
        root.selectedIndex = (root.selectedIndex - 1 + root.actions.length) % root.actions.length
    }
    Keys.onRightPressed: {
        root.selectedIndex = (root.selectedIndex + 1) % root.actions.length
    }
    Keys.onReturnPressed: root.runAction(root.selectedIndex)
    Keys.onEnterPressed: root.runAction(root.selectedIndex)

    Row {
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: root.actions

            delegate: Item {
                id: btn
                required property var modelData
                required property int index

                width: 64
                height: 72

                property bool hovered: false
                readonly property bool isSelected: root.selectedIndex === btn.index

                Rectangle {
                    id: btnBg
                    anchors.centerIn: parent
                    width: 64
                    height: 72
                    radius: Radius.large

                    color: (btn.hovered || btn.isSelected) ? Qt.alpha(btn.modelData.accentColor, 0.15) : Colors.tileBg
                    border.color: (btn.hovered || btn.isSelected) ? Qt.alpha(btn.modelData.accentColor, 0.5) : Colors.tileBorder
                    border.width: btn.isSelected ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }

                    transform: Scale {
                        id: btnScale
                        origin.x: btnBg.width / 2
                        origin.y: btnBg.height / 2
                        xScale: (btn.hovered || btn.isSelected) ? 1.08 : 1.0
                        yScale: (btn.hovered || btn.isSelected) ? 1.08 : 1.0

                        Behavior on xScale { NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
                        Behavior on yScale { NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btn.modelData.icon
                            color: (btn.hovered || btn.isSelected) ? btn.modelData.accentColor : Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 20
                            renderType: Text.NativeRendering

                            Behavior on color { ColorAnimation { duration: 140 } }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btn.modelData.label
                            color: (btn.hovered || btn.isSelected) ? btn.modelData.accentColor : Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: btn.isSelected
                            renderType: Text.NativeRendering

                            Behavior on color { ColorAnimation { duration: 140 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            btn.hovered = true
                            root.selectedIndex = btn.index
                        }
                        onExited: btn.hovered = false
                        onClicked: root.runAction(btn.index)
                    }
                }
            }
        }
    }
}
