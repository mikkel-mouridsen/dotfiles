pragma Singleton
import QtQuick

QtObject {
    // Catppuccin Mocha palette
    readonly property color background: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color overlay1: "#7f849c"
    readonly property color text: "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color subtext1: "#bac2de"
    readonly property color accent: "#cba6f7"    // mauve
    readonly property color red: "#f38ba8"
    readonly property color green: "#a6e3a1"
    readonly property color blue: "#89b4fa"
    readonly property color yellow: "#f9e2af"
    readonly property color peach: "#fab387"
    readonly property color teal: "#94e2d5"
    readonly property color sky: "#89dceb"
    readonly property color sapphire: "#74c7ec"
    readonly property color rosewater: "#f5e0dc"
    readonly property color lavender: "#b4befe"
    readonly property color flamingo: "#f2cdcd"
    readonly property color maroon: "#eba0ac"
    readonly property color mauve: "#cba6f7"

    // Glass effect helpers
    readonly property color glass: Qt.rgba(0.118, 0.118, 0.180, 0.75)       // base @ 75%
    readonly property color glassBorder: Qt.rgba(0.271, 0.278, 0.353, 0.35) // surface1 @ 35%
}
