import "../../"
import QtQuick

Item {
    id: root

    property var system
    property bool active: false

    readonly property int level: system ? system.batteryLevel : 0
    readonly property bool charging: system ? system.isCharging : false

    readonly property color levelColor: {
        if (charging) return Colors.green
        if (level < 20) return Colors.red
        if (level < 50) return Colors.orange
        return Colors.text
    }

    function pulse() {
        battIconPulse.restart()
    }

    width: 200
    height: parent ? parent.height : 32
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.85
    y: active ? 0 : 4
    visible: opacity > 0

    Row {
        anchors.centerIn: parent
        spacing: 8

        Item {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: battIcon
                anchors.centerIn: parent

                text: {
                    if (root.charging) return "󰂄"
                    if (root.level < 20) return "\uf244"
                    if (root.level < 40) return "\uf243"
                    if (root.level < 60) return "\uf242"
                    if (root.level < 80) return "\uf241"
                    return "\uf240"
                }
                color: root.levelColor
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                renderType: Text.NativeRendering
                rotation: -90 

                SequentialAnimation {
                    id: battIconPulse

                    NumberAnimation {
                        target: battIcon
                        property: "scale"
                        to: 1.3
                        duration: 80
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: battIcon
                        property: "scale"
                        to: 1
                        duration: 120
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }

        Text {
            id: battText

            text: (root.charging ? "Charging " : "Discharging ") + root.level + "%"
            color: root.levelColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation {
                    duration: 150
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
