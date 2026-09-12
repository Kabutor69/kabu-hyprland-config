import QtQuick
pragma Singleton

QtObject {
    readonly property color islandBg: "#ffffff"   
    readonly property color islandBorder: "#d3c2c9"
    readonly property color islandBorderMuted: "#827379"
    readonly property color bg: "#fff8f8"
    
    // Dynamic Material You Surfaces & Containers
    readonly property color surface: "#ffffff"
    readonly property color elevated: "#f3e4e9"
    readonly property color border: "#d3c2c9"
    readonly property color borderLight: "#827379"

    // Dynamic Material You Accents
    readonly property color blue: "#874b6d"
    readonly property color blueMuted: "#ffd8ea"
    readonly property color cyan: "#715764"
    readonly property color purple: "#80543c"
    readonly property color green: "#874b6d"
    readonly property color yellow: "#80543c"
    readonly property color orange: "#fcd9e9"
    readonly property color red: "#ba1a1a"
    readonly property color pink: "#ffdbca"

    // Control Accents
    readonly property color volumeAccent: blue
    readonly property color brightnessAccent: yellow
    readonly property color muteAccent: red
    readonly property color osdTrackBg: "#f9eaef"

    // Typography
    readonly property color text: "#211a1d"
    readonly property color textSecondary: "#504349"
    readonly property color disabled: "#827379"
    readonly property color muted: "#d3c2c9"

    // Workspaces
    readonly property color workspaceActive: "#874b6d"       
    readonly property color workspaceOccupied: "#504349"   
    readonly property color workspaceInactive: "#d3c2c9"   

    // Tiles & Cards
    readonly property color tileBg: "#fff0f5"
    readonly property color tileActiveBg: "#ffd8ea"
    readonly property color tileBorder: "#d3c2c9"
    readonly property color tileActiveBorder: "#874b6d"

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
