import "../"
import "../../"
import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspaceRow
    spacing: 5
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    property string side: "left"

    readonly property int workspaceOffset: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id > 6) ? 6 : 0
    readonly property int sideBaseOffset: (side === "right") ? 4 : 1

    Repeater {
        model: 3

        Rectangle {
            id: dot
            readonly property int targetWorkspaceId: index + sideBaseOffset + workspaceRow.workspaceOffset
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === targetWorkspaceId

            width: isFocused ? 16 : (dotMouse.containsMouse ? 9 : 6)
            height: Height.dot
            radius: Radius.dot

            color: isFocused
                   ? Colors.workspaceActive
                   : (dotMouse.containsMouse 
                       ? Colors.hover 
                       : Colors.workspaceInactive)

            MouseArea {
                id: dotMouse
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: Quickshell.execDetached([
                    "hyprctl",
                    "dispatch",
                    "hl.dsp.focus({ workspace = " + dot.targetWorkspaceId + " })"
                ])
            }

            Behavior on width {
                NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }
}
