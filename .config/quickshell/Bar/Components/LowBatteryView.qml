import "../../"
import QtQuick

Item {
    id: root

    property var system
    property bool active: false

    function pulse() {
        flashAnim.restart()
    }

    width: 210
    height: parent ? parent.height : 32
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.85
    y: active ? 0 : 4
    visible: opacity > 0

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: warnIcon
            text: "\udb80\udc83" 
            color: Colors.red
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering

            SequentialAnimation {
                running: root.active
                loops: Animation.Infinite

                NumberAnimation {
                    target: warnIcon
                    property: "opacity"
                    to: 0.35
                    duration: 500
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    target: warnIcon
                    property: "opacity"
                    to: 1.0
                    duration: 500
                    easing.type: Easing.InOutSine
                }
            }
        }

        Text {
            id: warnText
            text: "Low Battery " + (root.system ? root.system.batteryLevel : 0) + "%"
            color: Colors.red
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
        }
    }

    SequentialAnimation {
        id: flashAnim

        NumberAnimation {
            target: root
            property: "scale"
            to: 1.08
            duration: 90
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 140
            easing.type: Easing.OutBack
            easing.overshoot: 1.3
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
