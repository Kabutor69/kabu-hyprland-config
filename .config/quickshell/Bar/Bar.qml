import "../"
import "./OSD"
import "./Clock_Workspace"
import "./Components"

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: islandContainer

    property string currentMode: "NORMAL"
    property var activeTrayMenu: null

    function toggleDrawer() {
        if (currentMode === "DRAWER") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "DRAWER"
            appDrawerView.reset()
            appDrawerView.focusSearch()
        }
    }

    function closeDrawer() {
        if (currentMode === "DRAWER")
            currentMode = "NORMAL"
    }

    function toggleWallpaper() {
        if (currentMode === "WALLPAPER") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "WALLPAPER"
            wallpaperView.pulse()
        }
    }

    function closeWallpaper() {
        if (currentMode === "WALLPAPER")
            currentMode = "NORMAL"
    }

    function toggleClipboard() {
        if (currentMode === "CLIPBOARD") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "CLIPBOARD"
        }
    }

    function closeClipboard() {
        if (currentMode === "CLIPBOARD")
            currentMode = "NORMAL"
    }

    function toggleTray() {
        if (currentMode === "TRAY") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "TRAY"
            trayView.pulse()
            osdTimeout.interval = 3200
            osdTimeout.restart()
        }
    }

    function openTrayMenu(menuHandle) {
        activeTrayMenu = menuHandle
        osdTimeout.stop()
        currentMode = "TRAYMENU"
        trayMenuView.pulse()
    }

    function closeTrayMenu() {
        if (currentMode === "TRAYMENU") {
            currentMode = "NORMAL"
            osdTimeout.stop()
        }
    }

    function toggleControlCenter() {
        if (currentMode === "CONTROLCENTER") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "CONTROLCENTER"
        }
    }

    function closeControlCenter() {
        if (currentMode === "CONTROLCENTER")
            currentMode = "NORMAL"
    }

    function toggleNotificationCenter() {
        if (currentMode === "NOTIFICATIONCENTER") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "NOTIFICATIONCENTER"
            notificationCenterView.pulse()
        }
    }

    function closeNotificationCenter() {
        if (currentMode === "NOTIFICATIONCENTER")
            currentMode = "NORMAL"
    }

    function togglePower() {
        if (currentMode === "POWER") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "POWER"
        }
    }

    function closePower() {
        if (currentMode === "POWER")
            currentMode = "NORMAL"
    }

    function toggleSystemMonitor() {
        if (currentMode === "SYSTEMMONITOR") {
            currentMode = "NORMAL"
        } else {
            osdTimeout.stop()
            currentMode = "SYSTEMMONITOR"
            systemMonitorView.pulse()
        }
    }

    function closeSystemMonitor() {
        if (currentMode === "SYSTEMMONITOR")
            currentMode = "NORMAL"
    }

    width:
        currentMode === "NORMAL" ? Wdth.normal
        : currentMode === "DRAWER" ? Wdth.drawer
        : currentMode === "WALLPAPER" ? Wdth.wallpaper
        : currentMode === "CLIPBOARD" ? Wdth.clipboard
        : currentMode === "NOTIFICATION" ? Wdth.notification
        : currentMode === "CHARGING" ? Wdth.charging
        : currentMode === "TRAY" ? Wdth.tray
        : currentMode === "TRAYMENU" ? Wdth.trayMenu
        : currentMode === "CONTROLCENTER" ? Wdth.controlCenter
        : currentMode === "NOTIFICATIONCENTER" ? Wdth.notificationCenter
        : currentMode === "LOWBATTERY" ? Wdth.lowBattery
        : currentMode === "POWER" ? Wdth.power
        : currentMode === "SYSTEMMONITOR" ? Wdth.systemMonitor
        : Wdth.defaultWidth

    height:
        currentMode === "DRAWER" ? Height.drawer
        : currentMode === "WALLPAPER" ? Height.wallpaper
        : currentMode === "CLIPBOARD" ? Height.clipboard
        : currentMode === "NOTIFICATION" ? Height.notification
        : currentMode === "CHARGING" ? Height.charging
        : currentMode === "TRAY"
            ? Math.min(
                Height.maxTray,
                Math.max(
                    Height.minTray,
                    trayView.contentHeight + Height.trayMargin
                )
            )
        : currentMode === "TRAYMENU"
            ? Math.min(
                Height.maxTray,
                Math.max(
                    Height.minTray,
                    trayMenuView.contentHeight + Height.trayMargin
                )
            )
        : currentMode === "CONTROLCENTER" ? Height.controlCenter
        : currentMode === "NOTIFICATIONCENTER" ? Height.notificationCenter
        : currentMode === "LOWBATTERY" ? Height.lowBattery
        : currentMode === "POWER" ? Height.power
        : currentMode === "SYSTEMMONITOR" ? Height.systemMonitor
        : Height.normal

    clip: true

    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: Radius.island
    bottomRightRadius: Radius.island

    color: Colors.islandBg
    border.width: 0

    layer.enabled: true

    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Colors.shadow
        shadowOpacity: 0.8
        shadowBlur: 1.0
        shadowVerticalOffset: 6
        shadowHorizontalOffset: 0
        shadowScale: 1.02
    }

    VolumeOSD {
        id: volSystem

        onVolumeChanged: {
            if (
                islandContainer.currentMode === "DRAWER" ||
                islandContainer.currentMode === "WALLPAPER" ||
                islandContainer.currentMode === "CLIPBOARD" ||
                islandContainer.currentMode === "CONTROLCENTER" ||
                islandContainer.currentMode === "NOTIFICATIONCENTER"
            )
                return

            volumeSliderView.pulse()
            islandContainer.currentMode = "VOLUME"

            osdTimeout.interval = 2200
            osdTimeout.restart()
        }
    }

    BrightnessOSD {
        id: brightSystem

        onBrightnessChanged: {
            if (
                islandContainer.currentMode === "DRAWER" ||
                islandContainer.currentMode === "WALLPAPER" ||
                islandContainer.currentMode === "CLIPBOARD" ||
                islandContainer.currentMode === "CONTROLCENTER" ||
                islandContainer.currentMode === "NOTIFICATIONCENTER"
            )
                return

            brightnessSliderView.pulse()
            islandContainer.currentMode = "BRIGHTNESS"

            osdTimeout.interval = 2200
            osdTimeout.restart()
        }
    }

    ChargingOSD {
        id: battSystem

        onChargingStateChanged: {
            if (
                islandContainer.currentMode === "DRAWER" ||
                islandContainer.currentMode === "WALLPAPER" ||
                islandContainer.currentMode === "CLIPBOARD" ||
                islandContainer.currentMode === "NOTIFICATIONCENTER"
            )
                return

            chargingView.pulse()
            islandContainer.currentMode = "CHARGING"

            osdTimeout.interval = 2200
            osdTimeout.restart()
        }

        onLowBatteryWarning: {
            if (
                islandContainer.currentMode === "DRAWER" ||
                islandContainer.currentMode === "WALLPAPER" ||
                islandContainer.currentMode === "CLIPBOARD" ||
                islandContainer.currentMode === "NOTIFICATIONCENTER"
            )
                return

            lowBatteryView.pulse()
            islandContainer.currentMode = "LOWBATTERY"

            osdTimeout.interval = 4000
            osdTimeout.restart()
        }
    }

    NotificationOSD {
        id: notifSystem

        onNotificationReceived: {
            if (
                islandContainer.currentMode === "DRAWER" ||
                islandContainer.currentMode === "WALLPAPER" ||
                islandContainer.currentMode === "CLIPBOARD" ||
                islandContainer.currentMode === "NOTIFICATIONCENTER"
            )
                return

            notificationView.pulse()
            islandContainer.currentMode = "NOTIFICATION"

            osdTimeout.interval = 3800
            osdTimeout.restart()
        }
    }

    SystemMonitorOSD { id: sysMonitor }
    NetworkOSD { id: wifiSystem }
    BluetoothOSD { id: btSystem }
    MicOSD { id: micSystem }
    CameraOSD { id: camSystem }
    CaffeineOSD { id: caffeineSystem }

    Timer {
        id: osdTimeout

        interval: 2200
        running: false
        repeat: false

        onTriggered: islandContainer.currentMode = "NORMAL"
    }

    Clock_Workspace {
        id: content

        anchors.fill: parent

        opacity: islandContainer.currentMode === "NORMAL" ? 1 : 0
        scale: islandContainer.currentMode === "NORMAL" ? 1 : 0.82
        y: islandContainer.currentMode === "NORMAL" ? 0 : -4

        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    TrayView {
        id: trayView

        active: islandContainer.currentMode === "TRAY"
        onMenuRequested: menu => islandContainer.openTrayMenu(menu)
        onCloseRequested: islandContainer.toggleTray()
    }

    TrayMenuView {
        id: trayMenuView

        active: islandContainer.currentMode === "TRAYMENU"
        menu: islandContainer.activeTrayMenu
        onCloseRequested: islandContainer.closeTrayMenu()
    }

    VolumeSliderView {
        id: volumeSliderView
        system: volSystem
        active: islandContainer.currentMode === "VOLUME"
    }

    BrightnessSliderView {
        id: brightnessSliderView
        system: brightSystem
        active: islandContainer.currentMode === "BRIGHTNESS"
    }

    ChargingView {
        id: chargingView
        system: battSystem
        active: islandContainer.currentMode === "CHARGING"
    }

    LowBatteryView {
        id: lowBatteryView
        system: battSystem
        active: islandContainer.currentMode === "LOWBATTERY"
    }

    NotificationView {
        id: notificationView
        system: notifSystem
        active: islandContainer.currentMode === "NOTIFICATION"
    }

    AppDrawerView {
        id: appDrawerView
        active: islandContainer.currentMode === "DRAWER"
        onCloseRequested: islandContainer.currentMode = "NORMAL"
    }

    WallpaperView {
        id: wallpaperView
        anchors.fill: parent
        active: islandContainer.currentMode === "WALLPAPER"
        onCloseRequested: islandContainer.currentMode = "NORMAL"
    }

    ClipboardView {
        id: clipboardView
        anchors.fill: parent
        active: islandContainer.currentMode === "CLIPBOARD"
        onCloseRequested: islandContainer.currentMode = "NORMAL"
    }

    ControlCenterView {
        id: controlCenterView

        active: islandContainer.currentMode === "CONTROLCENTER"
        wifiSystem: wifiSystem
        btSystem: btSystem
        micSystem: micSystem
        camSystem: camSystem
        caffeineSystem: caffeineSystem
        volSystem: volSystem
        brightSystem: brightSystem
        battSystem: battSystem

        onCloseRequested: islandContainer.closeControlCenter()
    }

    NotificationCenterView {
        id: notificationCenterView

        anchors.fill: parent
        active: islandContainer.currentMode === "NOTIFICATIONCENTER"
        system: notifSystem
        battSystem: battSystem

        onCloseRequested: islandContainer.closeNotificationCenter()
    }

    PowerOptionsView {
        id: powerOptionsView
        active: islandContainer.currentMode === "POWER"
        onCloseRequested: islandContainer.closePower()
    }

    SystemMonitorView {
        id: systemMonitorView
        active: islandContainer.currentMode === "SYSTEMMONITOR"
        system: sysMonitor
        onCloseRequested: islandContainer.closeSystemMonitor()
    }

    Behavior on width {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutExpo
        }
    }
}