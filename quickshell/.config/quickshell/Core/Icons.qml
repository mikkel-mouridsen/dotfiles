pragma Singleton
import QtQuick

QtObject {
    // Nerd Font icon mappings
    readonly property string arch: "\uf303"
    readonly property string workspace: "\uf4e2"
    readonly property string clock: "\uf64f"
    readonly property string battery_full: "\uf240"
    readonly property string battery_three_quarter: "\uf241"
    readonly property string battery_half: "\uf242"
    readonly property string battery_quarter: "\uf243"
    readonly property string battery_empty: "\uf244"
    readonly property string battery_charging: "\uf0e7"
    readonly property string volume_high: "\uf028"
    readonly property string volume_medium: "\uf027"
    readonly property string volume_low: "\uf026"
    readonly property string volume_mute: "\uf026"
    readonly property string power: "\u23fb"
    readonly property string lock: "\uf023"
    readonly property string suspend: "\uf186"
    readonly property string reboot: "\uf2f9"
    readonly property string shutdown: "\uf011"
    readonly property string logout: "\uf2f5"
    readonly property string music_play: "\uf04b"
    readonly property string music_pause: "\uf04c"
    readonly property string music_next: "\uf051"
    readonly property string music_prev: "\uf048"
    readonly property string search: "\uf002"
    readonly property string close: "\uf00d"
    readonly property string chevron_right: "\uf054"
    readonly property string chevron_down: "\uf078"
    readonly property string chevron_up: "\uf077"
    readonly property string music_note: "\uf001"
    readonly property string wifi: "\uf1eb"
    readonly property string wifi_off: "\uf6ac"
    readonly property string bluetooth: "\uf294"
    readonly property string bluetooth_off: "\uf295"
    readonly property string dnd: "\uf1f6"
    readonly property string bell: "\uf0f3"
    readonly property string signal_full: "\uf012"
    readonly property string profile_powersaver: "\uf06c"
    readonly property string profile_balanced: "\uf24e"
    readonly property string profile_performance: "\uf0e4"
    readonly property string notification: "\uf0a2"
    readonly property string clear_all: "\uf12d"
    readonly property string wallpaper: "\uf03e"

    function batteryIcon(percent, charging) {
        if (charging) return battery_charging
        if (percent > 75) return battery_full
        if (percent > 50) return battery_three_quarter
        if (percent > 25) return battery_half
        if (percent > 10) return battery_quarter
        return battery_empty
    }

    function volumeIcon(percent, muted) {
        if (muted) return volume_mute
        if (percent > 66) return volume_high
        if (percent > 33) return volume_medium
        return volume_low
    }
}
