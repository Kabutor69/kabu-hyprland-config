import "../"
import "../../"
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: volumeOsd

    property int volumeLevel: 0
    property bool isMuted: false
    property bool initialized: false

    signal volumeChanged()

    Component.onCompleted: volumeProber.running = true

    Process {
        id: volumeEventListener

        command: ["sh", "-c", "stdbuf -oL pactl subscribe | stdbuf -oL grep --line-buffered 'sink'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                volumeProber.running = false;
                volumeProber.running = true;
            }
        }

    }

    Process {
        id: volumeProber

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            onRead: (data) => {
                let cleanText = data.trim();
                let mutedState = cleanText.includes("MUTED");
                let matches = cleanText.match(/[0-9.]+/);
                if (matches) {
                    let newVol = Math.round(parseFloat(matches[0]) * 100);
                    if (volumeOsd.initialized) {
                        if (newVol !== volumeOsd.volumeLevel || mutedState !== volumeOsd.isMuted) {
                            volumeOsd.volumeLevel = newVol;
                            volumeOsd.isMuted = mutedState;
                            volumeOsd.volumeChanged();
                        }
                    } else {
                        volumeOsd.volumeLevel = newVol;
                        volumeOsd.isMuted = mutedState;
                        volumeOsd.initialized = true;
                    }
                }
            }
        }

    }

}
