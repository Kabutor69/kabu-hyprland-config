import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property bool active: false
    property var wifiSystem
    property var networks: []
    property var savedConnections: []
    property bool scanning: false

    property string connectingTo: ""
    property string forgettingSsid: ""
    property string connectError: ""
    property string passwordTargetSsid: ""

    signal closeRequested()

    function pulse() { flashAnim.restart() }

    function shQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function isKnownNetwork(ssid) {
        return savedConnections.indexOf(ssid) !== -1
    }

    function signalQuality(sig) {
        if (sig >= 75) return "Excellent"
        if (sig >= 50) return "Good"
        if (sig >= 25) return "Weak"
        return "Poor"
    }

    function signalColor(sig) {
        if (sig >= 75) return Colors.blue
        if (sig >= 50) return Colors.cyan
        if (sig >= 25) return Colors.purple
        return Colors.red
    }

    readonly property var connectedNetwork: {
        for (let i = 0; i < networks.length; i++) {
            if (networks[i].active) return networks[i]
        }
        return null
    }

    readonly property var availableNetworks: {
        const avail = []
        for (let i = 0; i < networks.length; i++) {
            if (!networks[i].active) avail.push(networks[i])
        }
        return avail
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: {
            if (root.passwordTargetSsid !== "") {
                root.passwordTargetSsid = ""
            } else {
                root.closeRequested()
            }
        }
    }

    onActiveChanged: {
        if (active) {
            root.passwordTargetSsid = ""
            root.connectError = ""
            savedConnProcess.running = true
            rescanProcess.running = true
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
        id: savedConnProcess
        running: false
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
                const saved = []
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":")
                    if (parts.length >= 2) {
                        const type = parts[parts.length - 1]
                        const name = parts.slice(0, parts.length - 1).join(":")
                        if (type === "802-11-wireless") {
                            saved.push(name)
                        }
                    }
                }
                root.savedConnections = saved
            }
        }
    }

    Process {
        id: rescanProcess
        command: ["nmcli", "dev", "wifi", "rescan"]
        onStarted: {
            root.scanning = true
            savedConnProcess.running = true
        }
        onExited: scanDelay.restart()
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
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = false
                const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
                const seen = {}
                const parsed = []

                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":")
                    if (parts.length < 4) continue

                    const security = parts[parts.length - 1]
                    const signal = parts[parts.length - 2]
                    const active = parts[0]
                    const ssid = parts.slice(1, parts.length - 2).join(":")

                    if (!ssid || seen[ssid]) continue
                    seen[ssid] = true

                    parsed.push({
                        ssid: ssid,
                        active: active === "yes",
                        signal: parseInt(signal) || 0,
                        secured: security !== "" && security !== "--",
                        security: security
                    })
                }

                parsed.sort((a, b) => {
                    if (a.active && !b.active) return -1
                    if (!a.active && b.active) return 1
                    return b.signal - a.signal
                })
                root.networks = parsed
            }
        }
    }

    Process {
        id: connectProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.connectingTo = ""
                if (text.toLowerCase().includes("error") || text.toLowerCase().includes("fail")) {
                    root.connectError = "Connection failed"
                } else {
                    root.connectError = ""
                    root.passwordTargetSsid = ""
                    savedConnProcess.running = true
                    listProcess.running = true
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.connectingTo = ""
                    root.connectError = "Connection failed"
                }
            }
        }
    }

    Process {
        id: forgetProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.forgettingSsid = ""
                savedConnProcess.running = true
                listProcess.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                root.forgettingSsid = ""
                savedConnProcess.running = true
                listProcess.running = true
            }
        }
    }

    Process { id: disconnectProcess }

    function requestConnect(ssid, secured) {
        root.connectError = ""

        if (isKnownNetwork(ssid) || !secured) {
            root.passwordTargetSsid = ""
            root.connectingTo = ssid
            connectProcess.command = ["nmcli", "dev", "wifi", "connect", ssid]
            connectProcess.running = true
            return
        }

        root.passwordTargetSsid = (root.passwordTargetSsid === ssid) ? "" : ssid
    }

    function connectWithPassword(ssid, password) {
        root.connectingTo = ssid
        root.connectError = ""
        connectProcess.command = ["sh", "-c",
            "nmcli dev wifi connect " + shQuote(ssid) + " password " + shQuote(password)
        ]
        connectProcess.running = true
    }

    function forgetNetwork(ssid) {
        if (!ssid) return
        root.forgettingSsid = ssid
        forgetProcess.command = ["nmcli", "connection", "delete", ssid]
        forgetProcess.running = true
    }

    function disconnectWifi() {
        disconnectProcess.command = ["nmcli", "dev", "disconnect", "wlan0"]
        disconnectProcess.running = true
        listProcess.running = true
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
                    text: "WI-FI"
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
                        onClicked: if (!root.scanning) rescanProcess.running = true
                    }
                }

                WifiToggle {
                    checked: root.wifiSystem ? root.wifiSystem.wifiEnabled : false
                    onToggled: if (root.wifiSystem) root.wifiSystem.toggle()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !(root.wifiSystem && root.wifiSystem.wifiEnabled)

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
                            text: "\uf1eb"
                            color: Colors.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            renderType: Text.NativeRendering
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Wi-Fi is off"
                        color: Colors.disabled
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        renderType: Text.NativeRendering
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Turn on to see available networks"
                        color: Colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.scanning && root.networks.length === 0 && (root.wifiSystem && root.wifiSystem.wifiEnabled)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "\uf1eb"
                        color: Colors.blue
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 28
                        renderType: Text.NativeRendering

                        SequentialAnimation on opacity {
                            running: root.scanning && root.networks.length === 0
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Looking for networks..."
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
                visible: root.connectedNetwork !== null && (root.wifiSystem && root.wifiSystem.wifiEnabled)

                color: Colors.tileActiveBg
                border.color: Colors.tileActiveBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: "\uf1eb"
                        color: Colors.blue
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        renderType: Text.NativeRendering
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.connectedNetwork ? root.connectedNetwork.ssid : ""
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
                                text: "•"
                                color: Colors.disabled
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 8
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: (root.connectedNetwork ? root.signalQuality(root.connectedNetwork.signal) : "") + "  " + (root.connectedNetwork ? root.connectedNetwork.signal : 0) + "%"
                                color: Colors.textSecondary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 8
                                renderType: Text.NativeRendering
                            }

                            Text {
                                visible: root.connectedNetwork && root.connectedNetwork.secured
                                text: "\uf023"
                                color: Colors.blue
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 8
                                renderType: Text.NativeRendering
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
                            text: root.forgettingSsid === (root.connectedNetwork ? root.connectedNetwork.ssid : "") ? "\uf110" : "\uf1f8"
                            color: forgetMa.containsMouse ? Colors.red : Colors.textSecondary
                            opacity: forgetMa.containsMouse ? 1.0 : 0.6
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            renderType: Text.NativeRendering

                            RotationAnimation on rotation {
                                running: root.forgettingSsid === (root.connectedNetwork ? root.connectedNetwork.ssid : "")
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
                                if (root.connectedNetwork) {
                                    root.forgetNetwork(root.connectedNetwork.ssid)
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
                        if (root.connectedNetwork) {
                            root.forgetNetwork(root.connectedNetwork.ssid)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.availableNetworks.length > 0 && (root.wifiSystem && root.wifiSystem.wifiEnabled)
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
                visible: root.availableNetworks.length > 0 && (root.wifiSystem && root.wifiSystem.wifiEnabled)
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
                    text: root.availableNetworks.length + ""
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
                visible: !root.scanning && root.networks.length === 0 && (root.wifiSystem && root.wifiSystem.wifiEnabled)

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
                        text: "No networks found"
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
                            onClicked: rescanProcess.running = true
                        }
                    }
                }
            }

            ListView {
                id: networkList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                visible: root.availableNetworks.length > 0 && (root.wifiSystem ? root.wifiSystem.wifiEnabled : true)
                model: root.availableNetworks

                delegate: Column {
                    id: networkDelegate
                    required property var modelData
                    required property int index
                    width: ListView.view ? ListView.view.width : 300
                    spacing: 0

                    readonly property bool isConnecting: root.connectingTo === modelData.ssid
                    readonly property bool isForgetting: root.forgettingSsid === modelData.ssid
                    readonly property bool isSaved: root.isKnownNetwork(modelData.ssid)
                    readonly property bool passwordOpen: root.passwordTargetSsid === modelData.ssid

                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: Radius.tile
                        color: rowMa.containsMouse ? Colors.elevated : Colors.tileBg
                        border.color: {
                            if (networkDelegate.isConnecting) return Colors.blue
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
                                text: "\uf1eb"
                                color: root.signalColor(networkDelegate.modelData.signal)
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                renderType: Text.NativeRendering
                                opacity: networkDelegate.modelData.signal >= 50 ? 1.0 : 0.7
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: networkDelegate.modelData.ssid
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
                                            if (networkDelegate.isConnecting) return "Connecting..."
                                            if (networkDelegate.isSaved) return "Saved"
                                            return root.signalQuality(networkDelegate.modelData.signal)
                                        }
                                        color: {
                                            if (networkDelegate.isConnecting) return Colors.blue
                                            if (networkDelegate.isSaved) return Colors.cyan
                                            return Colors.disabled
                                        }
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 8
                                        renderType: Text.NativeRendering

                                        SequentialAnimation on opacity {
                                            running: networkDelegate.isConnecting
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.3; duration: 500 }
                                            NumberAnimation { to: 1.0; duration: 500 }
                                        }
                                    }

                                    Text {
                                        visible: networkDelegate.modelData.secured
                                        text: "\uf023"
                                        color: networkDelegate.isSaved ? Colors.cyan : Colors.disabled
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 8
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }

                            Text {
                                text: networkDelegate.modelData.signal + "%"
                                color: root.signalColor(networkDelegate.modelData.signal)
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                                renderType: Text.NativeRendering
                            }

                            Rectangle {
                                visible: networkDelegate.isSaved
                                width: 24
                                height: 24
                                radius: Radius.medium
                                color: rowForgetMa.containsMouse ? Colors.red : "transparent"
                                opacity: rowForgetMa.containsMouse ? 0.9 : 0.5

                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on opacity { NumberAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: networkDelegate.isForgetting ? "\uf110" : "\uf1f8"
                                    color: rowForgetMa.containsMouse ? Colors.islandBg : Colors.disabled
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    renderType: Text.NativeRendering

                                    RotationAnimation on rotation {
                                        running: networkDelegate.isForgetting
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
                                    onClicked: root.forgetNetwork(networkDelegate.modelData.ssid)
                                }
                            }
                        }

                        MouseArea {
                            id: rowMa
                            anchors.fill: parent
                            anchors.rightMargin: networkDelegate.isSaved ? 28 : 0
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.requestConnect(networkDelegate.modelData.ssid, networkDelegate.modelData.secured)
                        }
                    }

                    Item {
                        width: parent.width
                        height: networkDelegate.passwordOpen ? pwCol.implicitHeight + 8 : 0
                        clip: true
                        visible: height > 0

                        Behavior on height {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        Column {
                            id: pwCol
                            width: parent.width
                            anchors.top: parent.top
                            anchors.topMargin: 6
                            spacing: 6

                            Rectangle {
                                width: parent.width
                                height: 36
                                radius: Radius.medium
                                color: Colors.tileBg
                                border.color: pwInput.activeFocus ? Colors.blue : Colors.tileBorder
                                border.width: 1

                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 6
                                    spacing: 8

                                    Text {
                                        text: "\uf023"
                                        color: pwInput.activeFocus ? Colors.blue : Colors.disabled
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        renderType: Text.NativeRendering

                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    TextInput {
                                        id: pwInput
                                        Layout.fillWidth: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: TextInput.Password
                                        color: Colors.text
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        clip: true

                                        Text {
                                            text: "Enter password"
                                            color: Colors.muted
                                            font: parent.font
                                            visible: pwInput.text.length === 0
                                            renderType: Text.NativeRendering
                                        }

                                        Keys.onReturnPressed: {
                                            if (text.length === 0) return
                                            root.connectWithPassword(networkDelegate.modelData.ssid, text)
                                        }

                                        Keys.onEscapePressed: root.passwordTargetSsid = ""

                                        onVisibleChanged: {
                                            if (visible) {
                                                text = ""
                                                forceActiveFocus()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 26
                                        height: 26
                                        radius: Radius.medium
                                        color: pwInput.text.length > 0
                                            ? (submitMa.containsMouse ? Colors.blue : Colors.blueMuted)
                                            : Colors.elevated
                                        opacity: pwInput.text.length > 0 ? 1 : 0.4

                                        Behavior on color { ColorAnimation { duration: 140 } }
                                        Behavior on opacity { NumberAnimation { duration: 140 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uf061"
                                            color: pwInput.text.length > 0 ? Colors.text : Colors.muted
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            renderType: Text.NativeRendering
                                        }

                                        MouseArea {
                                            id: submitMa
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            enabled: pwInput.text.length > 0
                                            onClicked: root.connectWithPassword(networkDelegate.modelData.ssid, pwInput.text)
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                visible: root.connectError !== "" && networkDelegate.passwordOpen
                                spacing: 4

                                Text {
                                    text: "\uf071"
                                    color: Colors.red
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: root.connectError
                                    color: Colors.red
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component WifiToggle: Rectangle {
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
