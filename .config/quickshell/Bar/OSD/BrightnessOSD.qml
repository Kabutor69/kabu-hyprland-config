import "../"
import "../../"
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: brightnessOsd

    property int brightnessLevel: 0
    property bool initialized: false

    signal brightnessChanged()

    Component.onCompleted: brightnessProber.running = true

    Process {
        id: brightnessEventListener

        command: ["sh", "-c", "stdbuf -oL udevadm monitor --subsystem-match=backlight | stdbuf -oL grep --line-buffered 'backlight'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                brightnessProber.running = false;
                brightnessProber.running = true;
            }
        }

    }

    Process {
        id: brightnessProber

        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]

        stdout: SplitParser {
            onRead: (data) => {
                let cleanText = data.trim();
                let newBright = parseInt(cleanText, 10);
                if (!isNaN(newBright)) {
                    if (brightnessOsd.initialized) {
                        if (newBright !== brightnessOsd.brightnessLevel) {
                            brightnessOsd.brightnessLevel = newBright;
                            brightnessOsd.brightnessChanged();
                        }
                    } else {
                        brightnessOsd.brightnessLevel = newBright;
                        brightnessOsd.initialized = true;
                    }
                }
            }
        }

    }

}
