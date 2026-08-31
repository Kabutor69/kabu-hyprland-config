import QtQuick
pragma Singleton

QtObject {
    readonly property color islandBg: "#000000"   
    readonly property color islandBorder: "#00000000"
    readonly property color islandBorderMuted: "#00000000"
    readonly property color bg: "#000000"
    
    // Dynamic Material You Surfaces & Containers
    readonly property color surface: "#0f0d12"
    readonly property color elevated: "#2c292f"
    readonly property color border: "#49454e"
    readonly property color borderLight: "#958e99"

    // Dynamic Material You Accents
    readonly property color blue: "#d5bbfc"
    readonly property color blueMuted: "#513c73"
    readonly property color cyan: "#cec2db"
    readonly property color purple: "#f1b7c3"
    readonly property color green: "#d5bbfc"
    readonly property color yellow: "#f1b7c3"
    readonly property color orange: "#4c4357"
    readonly property color red: "#ffb4ab"
    readonly property color pink: "#643b44"

    // Control Accents
    readonly property color volumeAccent: blue
    readonly property color brightnessAccent: yellow
    readonly property color muteAccent: red
    readonly property color osdTrackBg: "#211e24"

    // Typography
    readonly property color text: "#e7e0e8"
    readonly property color textSecondary: "#cbc4cf"
    readonly property color disabled: "#958e99"
    readonly property color muted: "#49454e"

    // Workspaces
    readonly property color workspaceActive: "#d5bbfc"       
    readonly property color workspaceOccupied: "#cbc4cf"   
    readonly property color workspaceInactive: "#49454e"   

    // Tiles & Cards
    readonly property color tileBg: "#1d1a20"
    readonly property color tileActiveBg: "#513c73"
    readonly property color tileBorder: "#49454e"
    readonly property color tileActiveBorder: "#d5bbfc"

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
