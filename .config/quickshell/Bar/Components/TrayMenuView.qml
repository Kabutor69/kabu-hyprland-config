import "../../"
import QtQuick
import Quickshell

Item {
    id: root

    property bool active: false
    property var menu: null 

    signal closeRequested()

    function pulse() {
        flashAnim.restart()
    }

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    readonly property int count: opener.children ? opener.children.values.length : 0
    readonly property real contentHeight: entryList.contentHeight

    Shortcut {
        sequence: "Escape"
        enabled: root.active
        onActivated: root.closeRequested()
    }

    width: parent ? parent.width : 220
    height: parent ? parent.height : 250
    opacity: active ? 1 : 0
    scale: active ? 1 : 0.85
    y: active ? 0 : 4
    visible: opacity > 0

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: root; property: "scale"; to: 1.06; duration: 80; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 130; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
    }

    Text {
        anchors.centerIn: parent
        visible: root.count === 0
        text: "No options"
        color: Colors.muted ? Colors.muted : "#71717A"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        renderType: Text.NativeRendering
    }

    ListView {
        id: entryList
        anchors.fill: parent
        anchors.margins: 6
        clip: true
        visible: root.count > 0
        model: opener.children ? opener.children.values : []
        spacing: 2

        delegate: Item {
            id: entryRow
            required property var modelData

            width: ListView.view ? ListView.view.width : 208
            height: modelData.isSeparator ? 9 : 32

            
            Rectangle {
                visible: entryRow.modelData.isSeparator
                anchors.centerIn: parent
                width: parent.width - 12
                height: 1
                color: Colors.border
            }

            
            Rectangle {
                id: entryBg
                visible: !entryRow.modelData.isSeparator
                anchors.fill: parent
                radius: Radius.small
                color: entryHover.containsMouse ? Colors.hover : Colors.transparent

                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Image {
                        width: 14
                        height: 14
                        anchors.verticalCenter: parent.verticalCenter
                        source: entryRow.modelData.icon || ""
                        visible: entryRow.modelData.icon !== "" && status === Image.Ready
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    Text {
                        text: entryRow.modelData.text || ""
                        color: entryRow.modelData.enabled === false 
                            ? Colors.disabled 
                            : Colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: parent.width - (entryRow.modelData.icon !== "" ? 22 : 0)
                        renderType: Text.NativeRendering
                    }
                }

                MouseArea {
                    id: entryHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: entryRow.modelData.enabled === false ? Qt.ArrowCursor : Qt.PointingHandCursor
                    enabled: entryRow.modelData.enabled !== false
                    onClicked: {
                        entryRow.modelData.triggered()
                        root.closeRequested()
                    }
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 240; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }
    Behavior on y {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
