import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    property var btSystem
    property var devices: []
    property bool scanning: false

    property string connectingTo: ""
    property string disconnectingFrom: ""
    property string unpairingMac: ""
    property string statusError: ""

    signal closeRequested()

    function pulse() { flashAnim.restart() }

    function deviceGlyph(icon, name) {
        const lowerName = (name || "").toLowerCase()
        const lowerIcon = (icon || "").toLowerCase()

        if (lowerIcon === "phone" || lowerName.includes("phone") || lowerName.includes("iphone") || lowerName.includes("android")) {
            return "\uf10b"
        }
        if (lowerIcon.includes("head") || lowerIcon.includes("audio") || lowerName.includes("headphone") || lowerName.includes("earphone") || lowerName.includes("earbuds") || lowerName.includes("airpods") || lowerName.includes("buds")) {
            return "\uf025"
        }
        if (lowerIcon.includes("speaker") || lowerName.includes("speaker") || lowerName.includes("soundbar")) {
            return "\uf028"
        }
        if (lowerIcon.includes("mouse") || lowerName.includes("mouse")) {
            return "\uf87c"
        }
        if (lowerIcon.includes("keyboard") || lowerName.includes("keyboard")) {
            return "\uf11c"
        }
        if (lowerIcon.includes("gamepad") || lowerIcon.includes("joystick") || lowerName.includes("controller") || lowerName.includes("gamepad")) {
            return "\uf11b"
        }
        if (lowerIcon.includes("computer") || lowerIcon.includes("laptop") || lowerName.includes("laptop") || lowerName.includes("pc")) {
            return "\uf109"
        }
        if (lowerIcon.includes("watch") || lowerName.includes("watch") || lowerName.includes("band")) {
            return "\uf017"
        }
        return "\uf294"
    }

    readonly property var connectedDevice: {
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected) return devices[i]
        }
        return null
    }

    readonly property var availableDevices: {
        const avail = []
        for (let i = 0; i < devices.length; i++) {
            if (!devices[i].connected) avail.push(devices[i])
        }
        return avail
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    onActiveChanged: {
        if (active) {
            root.statusError = ""
            listProcess.running = true
        }
    }

    anchors.fill: parent
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.94
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 1.08 }
    }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: root; property: "scale"; to: 1.02; duration: 90; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
    }

    Process {
        id: scanProcess
        command: ["bluetoothctl", "--timeout", "5", "scan", "on"]
        onStarted: root.scanning = true
        onExited: {
            root.scanning = false
            scanDelay.restart()
        }
    }

    Timer {
        id: scanDelay
        interval: 1200
        repeat: false
        onTriggered: listProcess.running = true
    }

    Process {
        id: listProcess
        running: false
        command: ["sh", "-c",
            "paired=$(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}'); " +
            "connected=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); " +
            "bluetoothctl devices 2>/dev/null | while IFS= read -r line; do " +
            "  [ -z \"$line\" ] && continue; " +
            "  mac=$(echo \"$line\" | awk '{print $2}'); " +
            "  name=$(echo \"$line\" | cut -d' ' -f3-); " +
            "  [ -z \"$mac\" ] && continue; " +
            "  info=$(bluetoothctl info \"$mac\" 2>/dev/null); " +
            "  alias=$(echo \"$info\" | grep 'Alias:' | head -n1 | cut -d' ' -f2-); " +
            "  [ -z \"$alias\" ] && alias=\"$name\"; " +
            "  icon=$(echo \"$info\" | grep 'Icon:' | head -n1 | awk '{print $2}'); " +
            "  bat=$(echo \"$info\" | grep 'Battery Percentage:' | head -n1 | sed -n 's/.*(\\([0-9]*\\))/\\1/p'); " +
            "  is_paired=0; " +
            "  is_conn=0; " +
            "  echo \"$paired\" | grep -q \"$mac\" && is_paired=1; " +
            "  echo \"$connected\" | grep -q \"$mac\" && is_conn=1; " +
            "  echo \"$mac|$alias|$is_conn|$is_paired|${icon:-generic}|${bat:--1}\"; " +
            "done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
                const parsed = []
                const seen = {}

                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split("|")
                    if (parts.length < 6) continue

                    const mac = parts[0]
                    if (!mac || seen[mac]) continue
                    seen[mac] = true

                    const name = parts[1] || mac
                    const isConn = parts[2] === "1"
                    const isPaired = parts[3] === "1"
                    const icon = parts[4] || "generic"
                    const bat = parseInt(parts[5])

                    parsed.push({
                        mac: mac,
                        name: name,
                        connected: isConn,
                        paired: isPaired,
                        icon: icon,
                        battery: isNaN(bat) ? -1 : bat
                    })
                }

                parsed.sort((a, b) => {
                    if (a.connected && !b.connected) return -1
                    if (!a.connected && b.connected) return 1
                    if (a.paired && !b.paired) return -1
                    if (!a.paired && b.paired) return 1
                    return a.name.localeCompare(b.name)
                })

                root.devices = parsed
            }
        }
    }

    Process {
        id: connectProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.connectingTo = ""
                if (text.toLowerCase().includes("failed") || text.toLowerCase().includes("error")) {
                    root.statusError = "Connection failed"
                } else {
                    root.statusError = ""
                }
                listProcess.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.connectingTo = ""
                    root.statusError = "Connection failed"
                    listProcess.running = true
                }
            }
        }
    }

    Process {
        id: disconnectProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.disconnectingFrom = ""
                listProcess.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                root.disconnectingFrom = ""
                listProcess.running = true
            }
        }
    }

    Process {
        id: removeProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.unpairingMac = ""
                listProcess.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                root.unpairingMac = ""
                listProcess.running = true
            }
        }
    }

    function requestConnect(mac, paired) {
        root.statusError = ""
        root.connectingTo = mac

        if (paired) {
            connectProcess.command = ["bluetoothctl", "connect", mac]
        } else {
            connectProcess.command = ["sh", "-c", "bluetoothctl --agent NoInputNoOutput pair " + mac + " && bluetoothctl trust " + mac + " && bluetoothctl connect " + mac]
        }
        connectProcess.running = true
    }

    function disconnectDevice(mac) {
        if (!mac) return
        root.disconnectingFrom = mac
        disconnectProcess.command = ["bluetoothctl", "disconnect", mac]
        disconnectProcess.running = true
    }

    function removeDevice(mac) {
        if (!mac) return
        root.unpairingMac = mac
        removeProcess.command = ["bluetoothctl", "remove", mac]
        removeProcess.running = true
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.islandBg

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "BLUETOOTH"
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.5
                    renderType: Text.NativeRendering
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: scanRow.implicitWidth + 16
                    implicitHeight: 22
                    radius: Radius.capsule
                    color: scanHover.containsMouse ? Colors.elevated : Colors.tileBg
                    border.color: root.scanning ? Colors.blue : Colors.tileBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        id: scanRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            id: scanIcon
                            text: "\uf021"
                            color: root.scanning ? Colors.blue : Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            renderType: Text.NativeRendering

                            RotationAnimation on rotation {
                                running: root.scanning
                                from: 0; to: 360
                                duration: 800
                                loops: Animation.Infinite
                            }
                            onRotationChanged: if (!root.scanning) rotation = 0
                        }

                        Text {
                            text: root.scanning ? "Scanning" : "Scan"
                            color: root.scanning ? Colors.blue : Colors.textSecondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                            renderType: Text.NativeRendering
                        }
                    }

                    MouseArea {
                        id: scanHover
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: if (!root.scanning) scanProcess.running = true
                    }
                }

                BtToggle {
                    checked: root.btSystem ? root.btSystem.isPowered : false
                    onToggled: if (root.btSystem) root.btSystem.toggle()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !(root.btSystem && root.btSystem.isPowered)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 14

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 52
                        height: 52
                        radius: Radius.capsule
                        color: Colors.elevated

                        Text {
                            anchors.centerIn: parent
                            text: "\uf294"
                            color: Colors.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            renderType: Text.NativeRendering
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Bluetooth is off"
                        color: Colors.disabled
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        renderType: Text.NativeRendering
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Turn on to discover paired & nearby devices"
                        color: Colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: false
                visible: root.scanning && root.devices.length === 0 && (root.btSystem && root.btSystem.isPowered)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "\uf294"
                        color: Colors.blue
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 28
                        renderType: Text.NativeRendering

                        SequentialAnimation on opacity {
                            running: root.scanning && root.devices.length === 0
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Looking for devices..."
                        color: Colors.textSecondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        renderType: Text.NativeRendering
                    }
                }
            }

            Rectangle {
                id: heroCard
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: Radius.tile
                visible: root.connectedDevice !== null && (root.btSystem && root.btSystem.isPowered)

                color: Colors.tileActiveBg
                border.color: Colors.tileActiveBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: root.connectedDevice ? root.deviceGlyph(root.connectedDevice.icon, root.connectedDevice.name) : "\uf294"
                        color: Colors.blue
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        renderType: Text.NativeRendering
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.connectedDevice ? root.connectedDevice.name : ""
                            color: Colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            renderType: Text.NativeRendering
                        }

                        RowLayout {
                            spacing: 6

                            Text {
                                text: "Connected"
                                color: Colors.blue
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 8
                                font.bold: true
                                renderType: Text.NativeRendering
                            }

                            Text {
                                visible: root.connectedDevice && root.connectedDevice.battery >= 0
                                text: "•"
                                color: Colors.disabled
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 8
                                renderType: Text.NativeRendering
                            }

                            RowLayout {
                                visible: root.connectedDevice && root.connectedDevice.battery >= 0
                                spacing: 3

                                Text {
                                    text: "\uf240"
                                    color: Colors.blue
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 8
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: (root.connectedDevice ? root.connectedDevice.battery : 0) + "%"
                                    color: Colors.textSecondary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 8
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: forgetBtn
                        width: 26
                        height: 26
                        radius: Radius.capsule
                        color: forgetMa.containsMouse ? "#33ffb4ab" : "transparent"

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.unpairingMac === (root.connectedDevice ? root.connectedDevice.mac : "") ? "\uf110" : "\uf1f8"
                            color: forgetMa.containsMouse ? Colors.red : Colors.textSecondary
                            opacity: forgetMa.containsMouse ? 1.0 : 0.6
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            renderType: Text.NativeRendering

                            RotationAnimation on rotation {
                                running: root.unpairingMac === (root.connectedDevice ? root.connectedDevice.mac : "")
                                from: 0; to: 360
                                duration: 800
                                loops: Animation.Infinite
                            }
                        }

                        MouseArea {
                            id: forgetMa
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                if (root.connectedDevice) {
                                    root.removeDevice(root.connectedDevice.mac)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.connectedDevice) {
                            root.removeDevice(root.connectedDevice.mac)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.availableDevices.length > 0 && (root.btSystem && root.btSystem.isPowered)
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.border
                    opacity: 0.4
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.availableDevices.length > 0 && (root.btSystem && root.btSystem.isPowered)
                spacing: 6

                Text {
                    text: "AVAILABLE"
                    color: Colors.disabled
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.2
                    renderType: Text.NativeRendering
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.availableDevices.length + ""
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !root.scanning && root.devices.length === 0 && (root.btSystem && root.btSystem.isPowered)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44
                        height: 44
                        radius: Radius.capsule
                        color: Colors.elevated

                        Text {
                            anchors.centerIn: parent
                            text: "\uf05a"
                            color: Colors.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            renderType: Text.NativeRendering
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No devices found"
                        color: Colors.disabled
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        renderType: Text.NativeRendering
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4
                        width: retryLabel.implicitWidth + 20
                        height: 24
                        radius: Radius.capsule
                        color: retryMa.containsMouse ? Colors.elevated : Colors.tileBg
                        border.color: Colors.tileBorder
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            id: retryLabel
                            anchors.centerIn: parent
                            text: "\uf021  Scan again"
                            color: Colors.blue
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: retryMa
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: scanProcess.running = true
                        }
                    }
                }
            }

            ListView {
                id: deviceList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                visible: root.availableDevices.length > 0 && (root.btSystem ? root.btSystem.isPowered : true)
                model: root.availableDevices

                delegate: Column {
                    id: deviceDelegate
                    required property var modelData
                    required property int index
                    width: ListView.view ? ListView.view.width : 300
                    spacing: 0

                    readonly property bool isConnecting: root.connectingTo === modelData.mac
                    readonly property bool isUnpairing: root.unpairingMac === modelData.mac
                    readonly property bool isPaired: modelData.paired

                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: Radius.tile
                        color: rowMa.containsMouse ? Colors.elevated : Colors.tileBg
                        border.color: {
                            if (deviceDelegate.isConnecting) return Colors.blue
                            if (rowMa.containsMouse) return Colors.borderLight
                            return Colors.tileBorder
                        }
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 10

                            Text {
                                text: root.deviceGlyph(deviceDelegate.modelData.icon, deviceDelegate.modelData.name)
                                color: deviceDelegate.isPaired ? Colors.blue : Colors.disabled
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                renderType: Text.NativeRendering
                                opacity: deviceDelegate.isPaired ? 1.0 : 0.7
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: deviceDelegate.modelData.name
                                    color: Colors.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    renderType: Text.NativeRendering
                                }

                                RowLayout {
                                    spacing: 5

                                    Text {
                                        text: {
                                            if (deviceDelegate.isConnecting) return "Connecting..."
                                            if (deviceDelegate.isPaired) return "Paired"
                                            return "Ready to pair"
                                        }
                                        color: {
                                            if (deviceDelegate.isConnecting) return Colors.blue
                                            if (deviceDelegate.isPaired) return Colors.cyan
                                            return Colors.disabled
                                        }
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 8
                                        renderType: Text.NativeRendering

                                        SequentialAnimation on opacity {
                                            running: deviceDelegate.isConnecting
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.3; duration: 500 }
                                            NumberAnimation { to: 1.0; duration: 500 }
                                        }
                                    }

                                    Text {
                                        visible: deviceDelegate.modelData.battery >= 0
                                        text: "•"
                                        color: Colors.disabled
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 8
                                        renderType: Text.NativeRendering
                                    }

                                    Text {
                                        visible: deviceDelegate.modelData.battery >= 0
                                        text: deviceDelegate.modelData.battery + "%"
                                        color: Colors.textSecondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 8
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }

                            Text {
                                visible: deviceDelegate.modelData.battery >= 0
                                text: deviceDelegate.modelData.battery + "%"
                                color: Colors.blue
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                                renderType: Text.NativeRendering
                            }

                            Rectangle {
                                visible: deviceDelegate.isPaired
                                width: 24
                                height: 24
                                radius: Radius.medium
                                color: rowForgetMa.containsMouse ? Colors.red : "transparent"
                                opacity: rowForgetMa.containsMouse ? 0.9 : 0.5

                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on opacity { NumberAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: deviceDelegate.isUnpairing ? "\uf110" : "\uf1f8"
                                    color: rowForgetMa.containsMouse ? Colors.islandBg : Colors.disabled
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    renderType: Text.NativeRendering

                                    RotationAnimation on rotation {
                                        running: deviceDelegate.isUnpairing
                                        from: 0; to: 360
                                        duration: 800
                                        loops: Animation.Infinite
                                    }
                                }

                                MouseArea {
                                    id: rowForgetMa
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: root.removeDevice(deviceDelegate.modelData.mac)
                                }
                            }
                        }

                        MouseArea {
                            id: rowMa
                            anchors.fill: parent
                            anchors.rightMargin: deviceDelegate.isPaired ? 28 : 0
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.requestConnect(deviceDelegate.modelData.mac, deviceDelegate.modelData.paired)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.statusError !== ""
                spacing: 4

                Text {
                    text: "\uf071"
                    color: Colors.red
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    renderType: Text.NativeRendering
                }

                Text {
                    text: root.statusError
                    color: Colors.red
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    renderType: Text.NativeRendering
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: root.connectedDevice !== null
                visible: root.connectedDevice !== null
            }
        }
    }

    component BtToggle: Rectangle {
        id: sw
        property bool checked: false
        signal toggled()

        width: 38
        height: 20
        radius: Radius.capsule
        color: checked ? Colors.blueMuted : Colors.elevated
        border.color: checked ? Colors.blue : Colors.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: 180 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }

        Rectangle {
            width: 14
            height: 14
            radius: Radius.capsule
            color: sw.checked ? Colors.blue : Colors.disabled
            anchors.verticalCenter: parent.verticalCenter
            x: sw.checked ? sw.width - width - 3 : 3

            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
            Behavior on color { ColorAnimation { duration: 180 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: sw.toggled()
        }
    }
}
