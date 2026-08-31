import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../../"

Item {
    id: chargingOsd

    readonly property UPowerDevice battery: UPower.displayDevice

    property int batteryLevel: 0
    property bool isCharging: false
    property bool initialized: false

    signal chargingStateChanged()

    signal lowBatteryWarning()

    property int lowBatteryThreshold: 20
    property int lowBatteryResetLevel: 25
    property bool lowBatteryWarned: false

    function computeCharging() {
        if (!battery || !battery.ready) return false
        return battery.state === UPowerDeviceState.Charging
            || battery.state === UPowerDeviceState.FullyCharged
    }

    function sync() {
        if (!battery || !battery.ready) return

        let level = Math.round(battery.percentage * 100)
        let charging = computeCharging()

        if (chargingOsd.initialized) {
            let stateFlipped = charging !== chargingOsd.isCharging
            chargingOsd.batteryLevel = level
            chargingOsd.isCharging = charging
            if (stateFlipped) {
                chargingOsd.chargingStateChanged()
            }
        } else {
            chargingOsd.batteryLevel = level
            chargingOsd.isCharging = charging
            chargingOsd.initialized = true
        }

        if (charging || level >= chargingOsd.lowBatteryResetLevel) {
            chargingOsd.lowBatteryWarned = false
        } else if (!charging && level <= chargingOsd.lowBatteryThreshold && !chargingOsd.lowBatteryWarned) {
            chargingOsd.lowBatteryWarned = true
            chargingOsd.lowBatteryWarning()
        }
    }

    Connections {
        target: chargingOsd.battery
        function onPercentageChanged() { chargingOsd.sync() }
        function onStateChanged() { chargingOsd.sync() }
        function onReadyChanged() { chargingOsd.sync() }
    }

    Component.onCompleted: sync()
}
