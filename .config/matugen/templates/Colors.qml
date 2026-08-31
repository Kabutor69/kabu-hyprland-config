import QtQuick
pragma Singleton

QtObject {
    readonly property color islandBg: "#000000"   
    readonly property color islandBorder: "#00000000"
    readonly property color islandBorderMuted: "#00000000"
    readonly property color bg: "#000000"
    
    // Dynamic Material You Surfaces & Containers
    readonly property color surface: "{{colors.surface_container_lowest.default.hex}}"
    readonly property color elevated: "{{colors.surface_container_high.default.hex}}"
    readonly property color border: "{{colors.outline_variant.default.hex}}"
    readonly property color borderLight: "{{colors.outline.default.hex}}"

    // Dynamic Material You Accents
    readonly property color blue: "{{colors.primary.default.hex}}"
    readonly property color blueMuted: "{{colors.primary_container.default.hex}}"
    readonly property color cyan: "{{colors.secondary.default.hex}}"
    readonly property color purple: "{{colors.tertiary.default.hex}}"
    readonly property color green: "{{colors.primary.default.hex}}"
    readonly property color yellow: "{{colors.tertiary.default.hex}}"
    readonly property color orange: "{{colors.secondary_container.default.hex}}"
    readonly property color red: "{{colors.error.default.hex}}"
    readonly property color pink: "{{colors.tertiary_container.default.hex}}"

    // Control Accents
    readonly property color volumeAccent: blue
    readonly property color brightnessAccent: yellow
    readonly property color muteAccent: red
    readonly property color osdTrackBg: "{{colors.surface_container.default.hex}}"

    // Typography
    readonly property color text: "{{colors.on_surface.default.hex}}"
    readonly property color textSecondary: "{{colors.on_surface_variant.default.hex}}"
    readonly property color disabled: "{{colors.outline.default.hex}}"
    readonly property color muted: "{{colors.outline_variant.default.hex}}"

    // Workspaces
    readonly property color workspaceActive: "{{colors.primary.default.hex}}"       
    readonly property color workspaceOccupied: "{{colors.on_surface_variant.default.hex}}"   
    readonly property color workspaceInactive: "{{colors.outline_variant.default.hex}}"   

    // Tiles & Cards
    readonly property color tileBg: "{{colors.surface_container_low.default.hex}}"
    readonly property color tileActiveBg: "{{colors.primary_container.default.hex}}"
    readonly property color tileBorder: "{{colors.outline_variant.default.hex}}"
    readonly property color tileActiveBorder: "{{colors.primary.default.hex}}"

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
