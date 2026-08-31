import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: sysMonitor

    property real cpuPercent: 0
    property real cpuTemp: 0
    property real memPercent: 0
    property real memUsed: 0
    property real memTotal: 0
    property real swapPercent: 0
    property real swapUsed: 0
    property real swapTotal: 0
    property real diskPercent: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property string uptime: ""

    width: 0
    height: 0

    function refresh() {
        cpuProber.running = false
        cpuProber.running = true

        memProber.running = false
        memProber.running = true

        swapProber.running = false
        swapProber.running = true

        diskProber.running = false
        diskProber.running = true

        tempProber.running = false
        tempProber.running = true

        uptimeProber.running = false
        uptimeProber.running = true
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: sysMonitor.refresh()
    }

    Process {
        id: cpuProber
        command: ["bash", "-lc", "top -bn1 | grep '%Cpu' | head -n 1 | awk '{print 100 - $8}' || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                const value = parseFloat(data.trim())
                if (!isNaN(value)) {
                    sysMonitor.cpuPercent = Math.max(0, Math.min(100, value))
                }
            }
        }
    }

    Process {
        id: memProber
        command: ["bash", "-lc", "free -m | awk '/^Mem:/ { printf \"%s %s\\n\", $3, $2 }' || echo '0 0'"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 2) {
                    const used = parseFloat(parts[0])
                    const total = parseFloat(parts[1])
                    if (!isNaN(used) && !isNaN(total) && total > 0) {
                        sysMonitor.memUsed = used / 1024
                        sysMonitor.memTotal = total / 1024
                        sysMonitor.memPercent = (used / total) * 100
                    }
                }
            }
        }
    }

    Process {
        id: swapProber
        command: ["bash", "-lc", "free -m | awk '/^Swap:/ { if ($2 == 0) print \"0 0\"; else printf \"%s %s\\n\", $3, $2 }' || echo '0 0'"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 2) {
                    const used = parseFloat(parts[0])
                    const total = parseFloat(parts[1])
                    if (!isNaN(used) && !isNaN(total) && total > 0) {
                        sysMonitor.swapUsed = used / 1024
                        sysMonitor.swapTotal = total / 1024
                        sysMonitor.swapPercent = (used / total) * 100
                    }
                }
            }
        }
    }

    Process {
        id: diskProber
        command: ["bash", "-lc", "df -B1 / | awk 'NR==2 { printf \"%s %s\\n\", $3, $2 }' || echo '0 0'"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 2) {
                    const used = parseFloat(parts[0])
                    const total = parseFloat(parts[1])
                    if (!isNaN(used) && !isNaN(total) && total > 0) {
                        sysMonitor.diskUsed = used / (1024 * 1024 * 1024)
                        sysMonitor.diskTotal = total / (1024 * 1024 * 1024)
                        sysMonitor.diskPercent = (used / total) * 100
                    }
                }
            }
        }
    }

    Process {
        id: tempProber
        command: ["bash", "-lc", "for f in /sys/class/thermal/thermal_zone*/temp; do [ -f \"$f\" ] || continue; v=$(cat \"$f\" 2>/dev/null | tr -d '\\n'); [ -n \"$v\" ] || continue; if [ \"$v\" -gt 0 ] 2>/dev/null; then awk -v val=\"$v\" 'BEGIN { printf \"%.0f\", val / 1000 }'; break; fi; done || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                const value = parseFloat(data.trim())
                if (!isNaN(value)) {
                    sysMonitor.cpuTemp = Math.max(0, value)
                }
            }
        }
    }

    Process {
        id: uptimeProber
        command: ["bash", "-lc", "uptime -p | sed 's/^up //'"]
        stdout: SplitParser {
            onRead: data => {
                const value = data.trim()
                if (value.length > 0) {
                    sysMonitor.uptime = value
                }
            }
        }
    }
}