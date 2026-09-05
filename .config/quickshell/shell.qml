import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "."
import "./Bar"

ShellRoot {

    
    Process {
        running: true
        command: ["hyprctl", "keyword", "layerrule", "blur,quickshell"]
    }
    Process {
        running: true
        command: ["hyprctl", "keyword", "layerrule", "ignorezero,quickshell"]
    }

    PanelWindow {
        id: panel

        screen: Quickshell.screens[0]

        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight:
            screen ? screen.height : 1080

        exclusiveZone: 28

        readonly property bool overlayModeActive:
            bar.currentMode === "DRAWER" ||
            bar.currentMode === "WALLPAPER" ||
            bar.currentMode === "CLIPBOARD" ||
            bar.currentMode === "TRAY" ||
            bar.currentMode === "TRAYMENU" ||
            bar.currentMode === "CONTROLCENTER" ||
            bar.currentMode === "NOTIFICATIONCENTER" ||
            bar.currentMode === "POWER" ||
            bar.currentMode === "SYSTEMMONITOR" ||
            bar.currentMode === "WIFILIST" ||
            bar.currentMode === "BLUETOOTHLIST"

        WlrLayershell.keyboardFocus:
            overlayModeActive
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        mask: Region {
            item: windowMaskRegion
        }

        IpcHandler {
            target: "drawer"
            function toggle(): void { bar.toggleDrawer() }
        }

        IpcHandler {
            target: "wallpaper"
            function toggle(): void { bar.toggleWallpaper() }
        }

        IpcHandler {
            target: "clipboard"
            function toggle(): void { bar.toggleClipboard() }
        }

        IpcHandler {
            target: "tray"
            function toggle(): void { bar.toggleTray() }
        }

        IpcHandler {
            target: "controlcenter"
            function toggle(): void { bar.toggleControlCenter() }
        }

        IpcHandler {
            target: "notifcenter"
            function toggle(): void { bar.toggleNotificationCenter() }
        }

        IpcHandler {
            target: "power"
            function toggle(): void { bar.togglePower() }
        }

        IpcHandler {
            target: "systemmonitor"
            function toggle(): void { bar.toggleSystemMonitor() }
        }

        IpcHandler {
            target: "wifilist"
            function toggle(): void { bar.toggleWifiList() }
        }

        IpcHandler {
            target: "bluetoothlist"
            function toggle(): void { bar.toggleBluetoothList() }
        }

        Item {
            id: windowMaskRegion

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            width:
                panel.overlayModeActive
                ? panel.width
                : bar.width + 40

            height:
                panel.overlayModeActive
                ? panel.height
                : bar.height

            MouseArea {
                anchors.fill: parent
                z: 0

                visible: panel.overlayModeActive
                enabled: panel.overlayModeActive

                onClicked: mouse => {
                    
                    if (mouse.x >= bar.x && mouse.x <= (bar.x + bar.width) &&
                        mouse.y >= bar.y && mouse.y <= (bar.y + bar.height)) {
                        return
                    }

                    if (bar.currentMode === "DRAWER") {
                        bar.closeDrawer()
                    } else if (bar.currentMode === "WALLPAPER") {
                        bar.closeWallpaper()
                    } else if (bar.currentMode === "CLIPBOARD") {
                        bar.closeClipboard()
                    } else if (bar.currentMode === "TRAYMENU") {
                        bar.closeTrayMenu()
                    } else if (bar.currentMode === "TRAY") {
                        bar.toggleTray()
                    } else if (bar.currentMode === "CONTROLCENTER") {
                        bar.closeControlCenter()
                    } else if (bar.currentMode === "NOTIFICATIONCENTER") {
                        bar.closeNotificationCenter()
                    } else if (bar.currentMode === "POWER") {
                        bar.closePower()
                    } else if (bar.currentMode === "SYSTEMMONITOR") {
                        bar.closeSystemMonitor()
                    } else if (bar.currentMode === "WIFILIST") {
                        bar.closeWifiList()
                    } else if (bar.currentMode === "BLUETOOTHLIST") {
                        bar.closeBluetoothList()
                    }
                }
            }

            Bar {
                id: bar
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                z: 1
            }
        }
      }
}
