import "../"
import "../../"
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: clockModule

    implicitWidth: clockText.implicitWidth + 12
    implicitHeight: parent ? parent.height : 26

    Process {
        id: trayToggle
        command: ["qs", "ipc", "call", "tray", "toggle"]
    }

    Process {
        id: systemMonitorToggle
        command: ["qs", "ipc", "call", "systemmonitor", "toggle"]
    }

    
    signal drawerRequested()

    Text {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatTime(new Date(), "HH:mm")
        color: Colors.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        font.bold: true
        renderType: Text.NativeRendering
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
    }

    MouseArea {
        id: clockArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                trayToggle.running = true
            }
            else if (mouse.button === Qt.LeftButton){
                systemMonitorToggle.running = true
            }
        }
    }
}
