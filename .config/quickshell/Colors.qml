import QtQuick
pragma Singleton

QtObject {
    readonly property color islandBg: "#000000"   
    readonly property color islandBorder: "#00000000"
    readonly property color islandBorderMuted: "#00000000"
    readonly property color bg: "#000000"
    
    // Dynamic Material You Surfaces & Containers
    readonly property color surface: "#090f10"
    readonly property color elevated: "#252b2c"
    readonly property color border: "#3f484a"
    readonly property color borderLight: "#899294"

    // Dynamic Material You Accents
    readonly property color blue: "#81d3de"
    readonly property color blueMuted: "#004f56"
    readonly property color cyan: "#b1cbcf"
    readonly property color purple: "#b8c6ea"
    readonly property color green: "#81d3de"
    readonly property color yellow: "#b8c6ea"
    readonly property color orange: "#324b4e"
    readonly property color red: "#ffb4ab"
    readonly property color pink: "#394664"

    // Control Accents
    readonly property color volumeAccent: blue
    readonly property color brightnessAccent: yellow
    readonly property color muteAccent: red
    readonly property color osdTrackBg: "#1a2121"

    // Typography
    readonly property color text: "#dee4e4"
    readonly property color textSecondary: "#bec8ca"
    readonly property color disabled: "#899294"
    readonly property color muted: "#3f484a"

    // Workspaces
    readonly property color workspaceActive: "#81d3de"       
    readonly property color workspaceOccupied: "#bec8ca"   
    readonly property color workspaceInactive: "#3f484a"   

    // Tiles & Cards
    readonly property color tileBg: "#171d1d"
    readonly property color tileActiveBg: "#004f56"
    readonly property color tileBorder: "#3f484a"
    readonly property color tileActiveBorder: "#81d3de"

    // Status
    readonly property color success: green
    readonly property color warning: yellow
    readonly property color danger: red

    // Utilities
    readonly property color hover: "#12FFFFFF"
    readonly property color pressed: "#20FFFFFF"
    readonly property color transparent: "#00000000"
    readonly property color overlay: "#E6000000"
    readonly property color shadow: "#B3000000"
}
