import "../../"
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property var wifiSystem
    property var btSystem
    property var micSystem
    property var camSystem
    property var caffeineSystem
    property var volSystem
    property var brightSystem
    property var battSystem

    signal closeRequested()
    signal wifiListRequested()
    signal bluetoothListRequested()

    width: parent ? parent.width : 380
    height: parent ? parent.height : 480

    function brightnessGlyph(level) {
        if (level <= 25) return "\uf185";
        if (level <= 66) return "\uf185";
        return "\uf185";
    }

    function volumeGlyph(level, muted) {
        if (muted || level <= 0) return "\uf026";
        if (level <= 33) return "\uf026";
        if (level <= 66) return "\uf027";
        return "\uf028";
    }

    opacity: active ? 1 : 0
    scale: active ? 1 : 0.95
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
        NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.05 }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    Timer {
        interval: 60000
        running: root.active
        repeat: true
        onTriggered: dateText.text = Qt.formatDate(new Date(), "dddd, MMM d")
    }

    Process { id: volSetProcess }
    Process { id: brightSetProcess }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Height.header

            Text {
                id: dateText
                text: Qt.formatDate(new Date(), "dddd, MMM d")
                color: Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: batteryIcon
                property bool charging: root.battSystem && root.battSystem.isCharging
                property int level: root.battSystem ? Math.round(root.battSystem.batteryLevel) : 100

                implicitWidth: 48
                implicitHeight: 22
                radius: Radius.capsule
                color: Colors.tileBg
                border.color: Colors.tileBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: batteryIcon.charging ? "\uf0e7" : (batteryIcon.level <= 20 ? "\uf244" : "\uf240")
                        color: batteryIcon.charging ? Colors.green : (batteryIcon.level <= 20 ? Colors.red : Colors.textSecondary)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    Text {
                        text: batteryIcon.level + "%"
                        color: Colors.textSecondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        
        Row {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            
            Column {
                width: parent.width * 0.68
                height: parent.height
                spacing: 8

                Row {
                    width: parent.width
                    height: (parent.height - 16) / 3
                    spacing: 8

                    ToggleTile {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        glyph: "\uf1eb"
                        label: "Wi-Fi"
                        statusText: root.wifiSystem && root.wifiSystem.wifiEnabled ? (root.wifiSystem.connectedSsid || "On") : "Off"
                        active: root.wifiSystem ? root.wifiSystem.wifiEnabled : false
                        onClicked: if (root.wifiSystem) root.wifiSystem.toggle()
                        onRightClicked: root.wifiListRequested()
                    }

                    ToggleTile {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        glyph: "\uf294"
                        label: "Bluetooth"
                        statusText: root.btSystem && root.btSystem.isPowered ? (root.btSystem.connectedDevice || "On") : "Off"
                        active: root.btSystem ? root.btSystem.isPowered : false
                        onClicked: if (root.btSystem) root.btSystem.toggle()
                        onRightClicked: root.bluetoothListRequested()
                    }
                }

                Row {
                    width: parent.width
                    height: (parent.height - 16) / 3
                    spacing: 8

                    ToggleTile {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        glyph: "\uf186"
                        label: "DND"
                        statusText: DndState.enabled ? "On" : "Off"
                        active: DndState.enabled
                        onClicked: DndState.enabled = !DndState.enabled
                    }

                    ToggleTile {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        glyph: "\uf0f4"
                        label: "Caffeine"
                        statusText: root.caffeineSystem && root.caffeineSystem.isActive ? "On" : "Off"
                        active: root.caffeineSystem ? root.caffeineSystem.isActive : false
                        onClicked: if (root.caffeineSystem) root.caffeineSystem.toggle()
                    }
                }

                Row {
                    width: parent.width
                    height: (parent.height - 16) / 3
                    spacing: 8

                    ToggleTile {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        glyph: "\uf030"
                        label: "Camera"
                        statusText: root.camSystem && root.camSystem.isOn ? "On" : "Off"
                        active: root.camSystem ? root.camSystem.isOn : false
                        onClicked: if (root.camSystem) root.camSystem.toggle()
                    }

                    ToggleTile {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        glyph: "\uf130"
                        label: "Mic"
                        statusText: root.micSystem && root.micSystem.isMuted ? "Muted" : "On"
                        active: root.micSystem ? !root.micSystem.isMuted : false
                        onClicked: if (root.micSystem) root.micSystem.toggle()
                    }
                }
            }

            
            Row {
                width: parent.width * 0.32 - 10
                height: parent.height
                spacing: 8

                
                VerticalBar {
                    width: (parent.width - 8) / 2
                    height: parent.height
                    glyph: root.brightSystem ? root.brightnessGlyph(root.brightSystem.brightnessLevel) : "\uf185"
                    level: root.brightSystem ? root.brightSystem.brightnessLevel : 50
                    fillColor: Colors.blue
                    onLevelDragged: (newLevel) => {
                        if (root.brightSystem && root.brightSystem.setBrightness) {
                            root.brightSystem.setBrightness(newLevel);
                        }
                        brightSetProcess.command = ["brightnessctl", "set", Math.max(1, newLevel) + "%"];
                        brightSetProcess.running = true;
                    }
                }

                
                VerticalBar {
                    width: (parent.width - 8) / 2
                    height: parent.height
                    glyph: root.volSystem ? root.volumeGlyph(root.volSystem.volumeLevel, root.volSystem.isMuted) : "\uf028"
                    level: (root.volSystem && root.volSystem.isMuted) ? 100 : (root.volSystem ? root.volSystem.volumeLevel : 50)
                    fillColor: (root.volSystem && root.volSystem.isMuted) ? Colors.red : Colors.blue
                    onLevelDragged: (newLevel) => {
                        if (root.volSystem) {
                            if (root.volSystem.isMuted) root.volSystem.isMuted = false;
                            if (root.volSystem.setVolume) root.volSystem.setVolume(newLevel);
                            else root.volSystem.volumeLevel = newLevel;
                        }
                        volSetProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", newLevel + "%"];
                        volSetProcess.running = true;
                    }
                }
            }
        }

        
        MediaControlCard {
            id: mediaCard
            Layout.fillWidth: true
            Layout.preferredHeight: 104
        }
    }

    
    component ToggleTile: Rectangle {
        id: tile
        property string glyph: ""
        property string label: ""
        property string statusText: ""
        property bool active: false

        signal clicked()
        signal rightClicked()

        radius: Radius.tile
        color: active ? Colors.tileActiveBg : Colors.tileBg
        border.color: active ? Colors.tileActiveBorder : Colors.tileBorder
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Text {
                text: tile.glyph
                color: tile.active ? Colors.blue : Colors.textSecondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                width: parent.width - 24

                Text {
                    text: tile.label
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                    renderType: Text.NativeRendering
                }

                Text {
                    text: tile.statusText
                    color: tile.active ? Colors.text : Colors.textSecondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    width: parent.width
                    renderType: Text.NativeRendering
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onEntered: if (!tile.active) tile.border.color = Colors.hover
            onExited: if (!tile.active) tile.border.color = Colors.tileBorder
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton)
                    tile.rightClicked()
                else
                    tile.clicked()
            }
        }

        Behavior on color { ColorAnimation { duration: 140 } }
    }

    
    component VerticalBar: Item {
        id: vbar
        property string glyph: ""
        property real level: 0
        property color fillColor: Colors.blue
        property bool seeking: false
        property real dragLevel: level

        signal levelDragged(real newLevel)

        Rectangle {
            id: bgCapsule
            anchors.fill: parent
            radius: Radius.slider
            color: Colors.tileBg
            border.color: Colors.tileBorder
            border.width: 1
        }

        Item {
            id: fillContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: fillContainer.width
                    height: fillContainer.height
                    radius: Radius.slider
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Math.max(0, Math.min(1, (vbar.seeking ? vbar.dragLevel : vbar.level) / 100)) * parent.height
                color: vbar.fillColor

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Behavior on height {
                    enabled: !vbar.seeking
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            text: vbar.glyph
            color: vbar.level > 20 ? Colors.text : Colors.textSecondary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            renderType: Text.NativeRendering
            z: 2
        }

        MouseArea {
            function setFromY(y) {
                const fraction = 1 - Math.max(0, Math.min(1, y / vbar.height));
                const targetLevel = Math.round(fraction * 100);
                    vbar.dragLevel = targetLevel;
                vbar.levelDragged(targetLevel);
            }

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            onPressed: (mouse) => { vbar.seeking = true; vbar.dragLevel = vbar.level; setFromY(mouse.y); }
            onPositionChanged: (mouse) => { if (pressed) setFromY(mouse.y); }
            onReleased: (mouse) => { setFromY(mouse.y); vbar.seeking = false; }
        }
    }
}