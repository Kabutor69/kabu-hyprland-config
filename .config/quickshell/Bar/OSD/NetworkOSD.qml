import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: netOsd

    property bool wifiEnabled: false
    property string connectedSsid: ""
    property bool initialized: false

    signal networkChanged()

    Process {
        id: eventListener
        command: ["sh", "-c", "stdbuf -oL nmcli monitor"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                prober.running = false
                prober.running = true
            }
        }
    }

    Process {
        id: prober
        command: ["sh", "-c",
            "echo \"$(nmcli -t -f WIFI radio),$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 | head -n1)\""
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(",")
                if (parts.length < 1) return

                const enabled = parts[0].trim() === "enabled"
                const ssid = parts.length > 1 ? parts.slice(1).join(",").trim() : ""

                if (netOsd.initialized) {
                    const changed = enabled !== netOsd.wifiEnabled || ssid !== netOsd.connectedSsid
                    netOsd.wifiEnabled = enabled
                    netOsd.connectedSsid = ssid
                    if (changed) netOsd.networkChanged()
                } else {
                    netOsd.wifiEnabled = enabled
                    netOsd.connectedSsid = ssid
                    netOsd.initialized = true
                }
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["nmcli", "radio", "wifi", netOsd.wifiEnabled ? "off" : "on"]
    }

    function toggle() {
        toggleProcess.running = true
    }

    Component.onCompleted: prober.running = true
}
