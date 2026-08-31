import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: micOsd

    property bool isMuted: false
    property bool initialized: false

    signal micChanged()

    Process {
        id: eventListener
        command: ["sh", "-c", "stdbuf -oL pactl subscribe | stdbuf -oL grep --line-buffered 'source'"]
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
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]

        stdout: SplitParser {
            onRead: data => {
                const muted = data.trim().includes("MUTED")
                if (micOsd.initialized) {
                    if (muted !== micOsd.isMuted) {
                        micOsd.isMuted = muted
                        micOsd.micChanged()
                    }
                } else {
                    micOsd.isMuted = muted
                    micOsd.initialized = true
                }
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
    }

    function toggle() {
        toggleProcess.running = true
    }

    Component.onCompleted: prober.running = true
}
