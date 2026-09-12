pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    property bool darkMode: true

    property var _loader: Process {
        id: loader
        running: true
        command: ["sh", "-c", "cat $HOME/.cache/theme-mode 2>/dev/null || echo dark"]
        stdout: StdioCollector {
            onStreamFinished: {
                const mode = text.trim()
                if (mode === "light") {
                    darkMode = false
                }
            }
        }
    }

    property var _saver: Process {
        id: saver
    }

    onDarkModeChanged: {
        saver.command = ["sh", "-c", "echo " + (darkMode ? "dark" : "light") + " > $HOME/.cache/theme-mode"]
        saver.running = true
    }
}
