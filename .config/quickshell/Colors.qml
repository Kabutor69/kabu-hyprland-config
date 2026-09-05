import QtQuick
pragma Singleton

QtObject {
    readonly property color islandBg: "#000000"   
    readonly property color islandBorder: "#00000000"
    readonly property color islandBorderMuted: "#00000000"
    readonly property color bg: "#000000"
    
    // Dynamic Material You Surfaces & Containers
    readonly property color surface: "#0d0e13"
    readonly property color elevated: "#292a2f"
    readonly property color border: "#45464f"
    readonly property color borderLight: "#8f909a"

    // Dynamic Material You Accents
    readonly property color blue: "#b3c5ff"
    readonly property color blueMuted: "#314578"
    readonly property color cyan: "#c0c6dd"
    readonly property color purple: "#e1bbdc"
    readonly property color green: "#b3c5ff"
    readonly property color yellow: "#e1bbdc"
    readonly property color orange: "#414659"
    readonly property color red: "#ffb4ab"
    readonly property color pink: "#5a3d58"

    // Control Accents
    readonly property color volumeAccent: blue
    readonly property color brightnessAccent: yellow
    readonly property color muteAccent: red
    readonly property color osdTrackBg: "#1e1f25"

    // Typography
    readonly property color text: "#e3e2e9"
    readonly property color textSecondary: "#c5c6d0"
    readonly property color disabled: "#8f909a"
    readonly property color muted: "#45464f"

    // Workspaces
    readonly property color workspaceActive: "#b3c5ff"       
    readonly property color workspaceOccupied: "#c5c6d0"   
    readonly property color workspaceInactive: "#45464f"   

    // Tiles & Cards
    readonly property color tileBg: "#1a1b21"
    readonly property color tileActiveBg: "#314578"
    readonly property color tileBorder: "#45464f"
    readonly property color tileActiveBorder: "#b3c5ff"

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
