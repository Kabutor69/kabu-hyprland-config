import "../"
import "../../"
import QtQuick

Item {
    id: root

    anchors.fill: parent

    Row {
        id: leftRowLayout

        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        WorkspaceDots {
            side: "left"
        }
    }

    ClockModule {
        anchors.centerIn: parent

        onDrawerRequested: {
            if (typeof islandContainer !== "undefined") {
                islandContainer.toggleDrawer()
            }
        }
    }

    WorkspaceDots {
        side: "right"
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }
}
