pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    property var defaultSink: Pipewire.defaultAudioSink

    readonly property int volume: Math.round((defaultSink?.audio?.volume ?? 0) * 100)
    readonly property bool muted: defaultSink?.audio?.mute ?? false

    function setVolume(percent) {
        if (defaultSink?.audio) {
            defaultSink.audio.volume = Math.max(0, Math.min(1.5, percent / 100))
        }
    }

    function toggleMute() {
        if (defaultSink?.audio) {
            defaultSink.audio.mute = !defaultSink.audio.mute
        }
    }

    function adjustVolume(delta) {
        setVolume(volume + delta)
    }
}
