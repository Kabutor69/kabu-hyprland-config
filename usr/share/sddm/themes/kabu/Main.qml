import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#000000"

    // --- Design DNA ---
    readonly property color accent: "#89b4fa"      
    readonly property color glassBg: "#1Affffff"   
    readonly property color glassBorder: "#25ffffff"
    readonly property string mainFont: "JetBrainsMono Nerd Font"

    Image {
        id: background
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.8 
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#aa000000" }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: "#aa000000" }
        }
    }

    Item {
        id: mainContent
        anchors.fill: parent
        anchors.leftMargin: 120
        opacity: 0 

        Column {
            id: mainLayout
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            // 1. Time & Date
            Column {
                spacing: -15
                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    font.family: mainFont
                    font.pixelSize: 130
                    font.weight: Font.Light
                    color: "#ffffff"
                }
                Text {
                    text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                    font.family: mainFont
                    font.pixelSize: 20
                    color: accent
                    opacity: 0.8
                    leftPadding: 10
                }
            }

            // 2. User Info
            Text {
                text: "Signed in as " + userModel.lastUser
                font.family: mainFont
                font.pixelSize: 14
                color: "#ffffff"
                opacity: 0.5
                leftPadding: 10
            }

            // 3. Password Box
            Rectangle {
                id: passwordBox
                width: 380
                height: 54
                radius: 12
                color: glassBg
                border.width: 1
                border.color: passwordField.activeFocus ? accent : glassBorder
                
                TextField {
                    id: passwordField
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    font.family: mainFont
                    font.pixelSize: 16
                    color: "#ffffff"
                    placeholderText: loginFailed ? "Access Denied" : "Enter Password"
                    placeholderTextColor: loginFailed ? "#f38ba8" : "#6c7086"
                    echoMode: TextInput.Password
                    focus: true
                    background: Rectangle { color: "transparent" }
                    onAccepted: login()
                }

                Behavior on border.color { ColorAnimation { duration: 200 } }
            }

            // 4. Action Row (Session + Power Buttons)
            Row {
                id: actionRow
                spacing: 12
                
                // Session Selection Pill
                Rectangle {
                    id: sessionPill
                    width: 220
                    height: 44
                    radius: 22
                    color: sessionMouse.containsMouse ? "#25ffffff" : glassBg
                    border.width: 1
                    border.color: glassBorder
                    
                    Text {
                        anchors.centerIn: parent
                        text: sessionList.currentItem ? sessionList.currentItem.sessionName : "Select Session"
                        font.family: mainFont
                        font.pixelSize: 12
                        color: "#ffffff"
                    }
                    MouseArea {
                        id: sessionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sessionPopup.opened ? sessionPopup.close() : sessionPopup.open()
                    }
                }

                // Power Buttons Repeater
                Repeater {
                    model: [
                        { icon: "󰐥", col: "#f38ba8", action: "powerOff" },
                        { icon: "󰜉", col: "#fab387", action: "reboot" },
                        { icon: "󰒲", col: "#a6e3a1", action: "suspend" }
                    ]
                    Rectangle {
                        id: powerBtn
                        width: 44
                        height: 44
                        radius: 22
                        color: btnMouse.containsMouse ? modelData.col : glassBg
                        border.width: 1
                        border.color: glassBorder
                        
                        scale: btnMouse.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Text { 
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 18
                            color: btnMouse.containsMouse ? "#11111b" : modelData.col 
                        }
                        
                        MouseArea { 
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.action === "powerOff") sddm.powerOff();
                                else if (modelData.action === "reboot") sddm.reboot();
                                else if (modelData.action === "suspend") sddm.suspend();
                            }
                        }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }
        }

        // --- SESSION POPUP ---
        Popup {
            id: sessionPopup
            parent: sessionPill 
            x: 0
            y: -height - 10 
            width: sessionPill.width
            padding: 8
            
            enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 } }
            exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 } }

            background: Rectangle {
                color: "#1e1e2e" 
                radius: 12
                border.color: accent
                border.width: 1
                opacity: 0.95
            }

            contentItem: ListView {
                id: sessionList
                implicitHeight: Math.min(contentHeight, 200)
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                clip: true

                delegate: ItemDelegate {
                    width: parent.width
                    height: 36
                    property string sessionName: name 
                    
                    background: Rectangle {
                        color: highlighted ? accent : "transparent"
                        opacity: highlighted ? 0.2 : 1.0
                        radius: 6
                    }

                    contentItem: Text {
                        text: name
                        color: highlighted ? "#ffffff" : "#a6adc8"
                        font.family: mainFont
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }

                    onClicked: {
                        sessionList.currentIndex = index
                        sessionPopup.close()
                    }
                }
            }
        }

        // --- ENTRY ANIMATIONS ---
        NumberAnimation { target: mainContent; property: "opacity"; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic; running: true }
        NumberAnimation { target: mainContent; property: "anchors.leftMargin"; from: 80; to: 120; duration: 800; easing.type: Easing.OutCubic; running: true }
    }

    // Arch Branding
    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40
        text: "ARCH LINUX  //  HYPRLAND"
        font.family: mainFont
        font.pixelSize: 10
        font.letterSpacing: 2
        color: "#ffffff"
        opacity: 0.2
    }

    // Logic Blocks
    property bool loginFailed: false
    function login() { sddm.login(userModel.lastUser, passwordField.text, sessionList.currentIndex) }

    Connections {
        target: sddm
        function onLoginFailed() { 
            loginFailed = true
            passwordField.text = ""
            errorTimer.start() 
        }
    }

    Timer { id: errorTimer; interval: 2000; onTriggered: loginFailed = false }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: timeText.text = Qt.formatDateTime(new Date(), "HH:mm") }
    Component.onCompleted: passwordField.forceActiveFocus()
}
