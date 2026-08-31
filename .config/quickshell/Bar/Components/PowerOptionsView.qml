import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    signal closeRequested()

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    anchors.fill: parent

    opacity: active ? 1 : 0
    scale: active ? 1 : 0.88
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }

    readonly property var actions: [
        {
            icon: "\uf023",
            label: "Lock",
            accentColor: Colors.blue,
            cmd: ["loginctl", "lock-session"]
        },
        {
            icon: "\uf2f5",
            label: "Logout",
            accentColor: Colors.yellow,
            cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"]
        },
        {
            icon: "\uf011",
            label: "Shutdown",
            accentColor: Colors.red,
            cmd: ["systemctl", "poweroff"]
        },
        {
            icon: "\uf01e",
            label: "Reboot",
            accentColor: Colors.orange,
            cmd: ["systemctl", "reboot"]
        }
    ]

    Row {
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: root.actions

            delegate: Item {
                id: btn
                required property var modelData

                width: 56
                height: 56

                property bool hovered: false

                Rectangle {
                    id: btnBg
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 56
                    height: 56
                    radius: Radius.large

                    color: btn.hovered ? Qt.alpha(btn.modelData.accentColor, 0.15) : Colors.tileBg
                    border.color: btn.hovered ? Qt.alpha(btn.modelData.accentColor, 0.5) : Colors.tileBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }

                    transform: Scale {
                        id: btnScale
                        origin.x: btnBg.width / 2
                        origin.y: btnBg.height / 2
                        xScale: btn.hovered ? 1.08 : 1.0
                        yScale: btn.hovered ? 1.08 : 1.0

                        Behavior on xScale { NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
                        Behavior on yScale { NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: btn.modelData.icon
                        color: btn.hovered ? btn.modelData.accentColor : Colors.textSecondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 20
                        renderType: Text.NativeRendering

                        Behavior on color { ColorAnimation { duration: 140 } }
                    }

                    Process {
                        id: actionProc
                        running: false
                        command: btn.modelData.cmd
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: btn.hovered = true
                        onExited: btn.hovered = false
                        onClicked: {
                            actionProc.running = true
                            root.closeRequested()
                        }
                    }
                }

            }
        }
    }
}
