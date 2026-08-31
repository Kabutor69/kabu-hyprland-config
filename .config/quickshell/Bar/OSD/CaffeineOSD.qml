import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: caffeineOsd

    property bool isActive: false
    property bool initialized: false

    signal caffeineChanged()

    Process {
        id: prober
        command: [Quickshell.env("HOME") + "/.local/bin/caffeine", "--is-running"]

        stdout: SplitParser {
            onRead: data => {
                const active = data.trim() === "true"
                if (caffeineOsd.initialized) {
                    if (active !== caffeineOsd.isActive) {
                        caffeineOsd.isActive = active
                        caffeineOsd.caffeineChanged()
                    }
                } else {
                    caffeineOsd.isActive = active
                    caffeineOsd.initialized = true
                }
            }
        }
    }

    Process {
        id: toggleProcess
        command: [Quickshell.env("HOME") + "/.local/bin/caffeine"]
        onExited: pollTimer.restart()
    }

    function toggle() {
        toggleProcess.running = true
    }

    Timer {
        id: pollTimer
        interval: 300
        repeat: false
        onTriggered: prober.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: prober.running = true
    }

    Component.onCompleted: prober.running = true
}
