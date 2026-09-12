import QtQuick
pragma Singleton

QtObject {
    readonly property color islandBg: "#ffffff"   
    readonly property color islandBorder: "#c7c5d0"
    readonly property color islandBorderMuted: "#777680"
    readonly property color bg: "#fbf8ff"
    
    // Dynamic Material You Surfaces & Containers
    readonly property color surface: "#ffffff"
    readonly property color elevated: "#eae7ef"
    readonly property color border: "#c7c5d0"
    readonly property color borderLight: "#777680"

    // Dynamic Material You Accents
    readonly property color blue: "#555a92"
    readonly property color blueMuted: "#e0e0ff"
    readonly property color cyan: "#5c5d72"
    readonly property color purple: "#78536b"
    readonly property color green: "#555a92"
    readonly property color yellow: "#78536b"
    readonly property color orange: "#e1e0f9"
    readonly property color red: "#ba1a1a"
    readonly property color pink: "#ffd8ee"

    // Control Accents
    readonly property color volumeAccent: blue
    readonly property color brightnessAccent: yellow
    readonly property color muteAccent: red
    readonly property color osdTrackBg: "#f0ecf4"

    // Typography
    readonly property color text: "#1b1b21"
    readonly property color textSecondary: "#46464f"
    readonly property color disabled: "#777680"
    readonly property color muted: "#c7c5d0"

    // Workspaces
    readonly property color workspaceActive: "#555a92"       
    readonly property color workspaceOccupied: "#46464f"   
    readonly property color workspaceInactive: "#c7c5d0"   

    // Tiles & Cards
    readonly property color tileBg: "#f5f2fa"
    readonly property color tileActiveBg: "#e0e0ff"
    readonly property color tileBorder: "#c7c5d0"
    readonly property color tileActiveBorder: "#555a92"

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
