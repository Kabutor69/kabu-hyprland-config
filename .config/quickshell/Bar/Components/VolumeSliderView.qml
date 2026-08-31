import "../../"
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var system
    property bool active: false

    function pulse() {
        volIconPulse.restart();
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
            id: volIcon

            text: (root.system && root.system.isMuted) ? "󰝟" : ((root.system && root.system.volumeLevel === 0) ? "󰝟" : ((root.system && root.system.volumeLevel < 33) ? "󰕿" : ((root.system && root.system.volumeLevel < 66) ? "󰖀" : "󰕾")))
            color: (root.system && root.system.isMuted) ? Colors.red : Colors.volumeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            scale: 1

            SequentialAnimation {
                id: volIconPulse

                NumberAnimation {
                    target: volIcon
                    property: "scale"
                    to: 1.3
                    duration: 80
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: volIcon
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

        
        Rectangle {
            id: volTrack

            width: 200 - volIcon.implicitWidth - volText.implicitWidth - 16
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
                    width: (root.system && root.system.isMuted) ? parent.width : Math.min(parent.width, Math.max(0, (parent.width * (root.system ? root.system.volumeLevel : 0)) / 100))
                    color: (root.system && root.system.isMuted) ? Colors.red : Colors.volumeAccent

                    Behavior on width {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }

        Text {
            id: volText

            text: (root.system && root.system.isMuted) ? "MUTED" : (root.system ? root.system.volumeLevel : 0) + "%"
            color: (root.system && root.system.isMuted) ? Colors.red : Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
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
