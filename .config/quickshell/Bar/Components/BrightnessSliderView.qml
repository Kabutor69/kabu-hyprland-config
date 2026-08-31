import "../../"
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var system
    property bool active: false

    function pulse() {
        brightIconPulse.restart();
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

        Text {
            id: brightIcon

            text: (root.system && root.system.brightnessLevel < 33) ? "󰃞" : ((root.system && root.system.brightnessLevel < 66) ? "󰃟" : "󰃠")
            color: Colors.brightnessAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            scale: 1

            SequentialAnimation {
                id: brightIconPulse

                NumberAnimation {
                    target: brightIcon
                    property: "scale"
                    to: 1.3
                    duration: 80
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: brightIcon
                    property: "scale"
                    to: 1
                    duration: 120
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }
        }

        
        Rectangle {
            id: brightTrack

            width: 200 - brightIcon.implicitWidth - brightText.implicitWidth - 16
            height: Height.dot
            radius: Radius.dot
            color: Colors.osdTrackBg
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: trackContainer
                anchors.fill: parent
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: trackContainer.width
                        height: trackContainer.height
                        radius: Radius.dot
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.min(parent.width, Math.max(0, (parent.width * (root.system ? root.system.brightnessLevel : 0)) / 100))
                    color: Colors.brightnessAccent

                    Behavior on width {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        Text {
            id: brightText

            text: (root.system ? root.system.brightnessLevel : 0) + "%"
            color: Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
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
