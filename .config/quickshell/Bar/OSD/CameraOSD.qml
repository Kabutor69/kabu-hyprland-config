import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: camOsd

    property bool isOn: false
    property bool initialized: false

    signal cameraChanged()

    Process {
        id: prober
        command: ["sh", "-c", "lsmod | grep -q uvcvideo && echo on || echo off"]

        stdout: SplitParser {
            onRead: data => {
                const on = data.trim() === "on"
                if (camOsd.initialized) {
                    if (on !== camOsd.isOn) {
                        camOsd.isOn = on
                        camOsd.cameraChanged()
                    }
                } else {
                    camOsd.isOn = on
                    camOsd.initialized = true
                }
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["bash", Quickshell.env("HOME") + "/.local/bin/camera-toggle"]
        onExited: pollTimer.restart()
    }

    function toggle() {
        toggleProcess.running = true
    }

    Timer {
        id: pollTimer
        interval: 800
        repeat: false
        onTriggered: prober.running = true
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: prober.running = true
    }

    Component.onCompleted: prober.running = true
}
