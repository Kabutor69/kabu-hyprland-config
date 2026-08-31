import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: btOsd

    property bool isPowered: false
    property string connectedDevice: ""
    property bool initialized: false

    signal bluetoothChanged()

    Process {
        id: prober
        command: ["sh", "-c",
            "powered=$(bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}'); " +
            "dev=$(bluetoothctl devices Connected 2>/dev/null | head -n1 | cut -d' ' -f3-); " +
            "echo \"$powered,$dev\""
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(",")
                const powered = parts[0] === "yes"
                const device = parts.length > 1 ? parts.slice(1).join(",").trim() : ""

                if (btOsd.initialized) {
                    const changed = powered !== btOsd.isPowered || device !== btOsd.connectedDevice
                    btOsd.isPowered = powered
                    btOsd.connectedDevice = device
                    if (changed) btOsd.bluetoothChanged()
                } else {
                    btOsd.isPowered = powered
                    btOsd.connectedDevice = device
                    btOsd.initialized = true
                }
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["bluetoothctl", "power", btOsd.isPowered ? "off" : "on"]
        onExited: pollTimer.restart()
    }

    function toggle() {
        toggleProcess.running = true
    }

    Timer {
        id: pollTimer
        interval: 600
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
