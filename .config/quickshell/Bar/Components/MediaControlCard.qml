import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../"

Item {
    id: root

    implicitWidth: parent ? parent.width : 360
    implicitHeight: 110

    property var activePlayer: {
        const players = Mpris.players.values;
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying) return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    property bool isPlaying: activePlayer && activePlayer.isPlaying
    property real trackLength: {
        if (!activePlayer) return 0;
        if (activePlayer.length > 0) return activePlayer.length;
        if (activePlayer.metadata && activePlayer.metadata["mpris:length"])
            return Number(activePlayer.metadata["mpris:length"]);
        return 0;
    }

    property real currentPos: activePlayer ? activePlayer.position : 0
    property bool seeking: false

    function sanitizeUrl(urlStr) {
        if (!urlStr || urlStr === "") return "";
        if (urlStr.startsWith("/")) return "file://" + urlStr;
        return urlStr;
    }

    property string artworkUrl: {
        if (!activePlayer) return "";
        if (activePlayer.trackArtUrl) return sanitizeUrl(activePlayer.trackArtUrl);
        if (activePlayer.metadata && activePlayer.metadata["mpris:artUrl"])
            return sanitizeUrl(activePlayer.metadata["mpris:artUrl"]);
        if (activePlayer.icon) return sanitizeUrl(activePlayer.icon);
        if (activePlayer.entryIcon) return sanitizeUrl(activePlayer.entryIcon);
        return "";
    }

    property string artistName: {
        if (!activePlayer) return "";
        if (activePlayer.trackArtist !== undefined && activePlayer.trackArtist)
            return String(activePlayer.trackArtist);
        if (activePlayer.metadata) {
            let artist = activePlayer.metadata["xesam:artist"];
            if (artist instanceof Array) return artist.join(", ");
            if (artist) return String(artist);
            artist = activePlayer.metadata["xesam:albumArtist"];
            if (artist instanceof Array) return artist.join(", ");
            if (artist) return String(artist);
        }
        return "";
    }

    Timer {
        interval: 500
        running: root.isPlaying && !root.seeking
        repeat: true
        onTriggered: {
            if (root.activePlayer) root.currentPos = root.activePlayer.position;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Radius.card
        color: Colors.tileBg
        border.color: Colors.tileBorder
        border.width: 1
        clip: true

        
        Image {
            id: albumArt
            anchors.fill: parent
            source: root.artworkUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: status === Image.Ready
            opacity: 0.3
        }

        
        ColumnLayout {
            anchors.centerIn: parent
            visible: !root.activePlayer
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "\uf001"
                color: Qt.rgba(1, 1, 1, 0.25)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "No Media Playing"
                color: Colors.muted ? Colors.muted : "#71717A"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }
        }

        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            visible: !!root.activePlayer

            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.activePlayer ? (root.activePlayer.trackTitle || "Unknown Track") : ""
                        color: Colors.text ? Colors.text : "#FFFFFF"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.artistName !== "" ? root.artistName : "Unknown Artist"
                        color: Colors.textSecondary ? Colors.textSecondary : "#A1A1AA"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: playHover.containsMouse ? Colors.blue : Colors.hover

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "\uf04c" : "\uf04b"
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: playHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePlayer) root.activePlayer.isPlaying = !root.activePlayer.isPlaying;
                        }
                    }
                }
            }

            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                
                Text {
                    text: "\uf048"
                    color: prevMouse.containsMouse ? "#FFFFFF" : Colors.textSecondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.activePlayer) root.activePlayer.previous()
                    }
                }

                
                Rectangle {
                    id: progressContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: Height.dot
                    radius: Radius.dot
                    color: Colors.osdTrackBg
                    clip: true

                    Rectangle {
                        height: parent.height
                        radius: Radius.dot
                        color: Colors.blue
                        width: root.trackLength > 0
                               ? Math.max(0, Math.min(1, root.currentPos / root.trackLength)) * parent.width
                               : 0

                        Behavior on width {
                            enabled: !root.seeking
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        preventStealing: true

                        function seekToX(px) {
                            if (!root.activePlayer || root.trackLength <= 0) return;
                            const fraction = Math.max(0, Math.min(1, px / progressContainer.width));
                            const newPos = fraction * root.trackLength;
                            const player = root.activePlayer;

                            if (typeof player.seek === "function") player.seek(newPos - player.position);
                            else player.position = newPos;
                            root.currentPos = newPos;
                        }

                        onPressed: mouse => { root.seeking = true; seekToX(mouse.x); }
                        onPositionChanged: mouse => { if (pressed) seekToX(mouse.x); }
                        onReleased: mouse => { seekToX(mouse.x); root.seeking = false; }
                    }
                }

                
                Text {
                    text: "\uf051"
                    color: nextMouse.containsMouse ? "#FFFFFF" : Colors.textSecondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.activePlayer) root.activePlayer.next()
                    }
                }
            }
        }
    }
}