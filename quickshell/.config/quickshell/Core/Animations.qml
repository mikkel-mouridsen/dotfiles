pragma Singleton
import QtQuick

QtObject {
    readonly property int durationFast: 150
    readonly property int durationNormal: 250
    readonly property int durationSlow: 400

    readonly property int easingType: Easing.OutCubic
    readonly property int easingBounce: Easing.OutBack
}
